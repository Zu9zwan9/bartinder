import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/bar.dart';
import '../blocs/bars/bars_bloc.dart';
import '../blocs/bars/bars_event.dart';
import '../blocs/bars/bars_state.dart';
import '../theme/theme.dart';
import '../widgets/bar_detail_screen.dart';
import '../widgets/distance_filter_widget.dart';

/// Screen for displaying and interacting with bars on map
class BarsScreen extends StatefulWidget {
  const BarsScreen({super.key});

  @override
  State<BarsScreen> createState() => _BarsScreenState();
}

class _BarsScreenState extends State<BarsScreen> {
  late final BarsBloc _barsBloc;
  bool _showDistanceFilter = false;
  double _currentMaxDistance = 25.0;
  MapController? _mapController;
  Bar? _selectedBar;

  // Значение по умолчанию для центра карты (если геолокация недоступна)
  static const double _defaultLatitude = 55.7558;
  static const double _defaultLongitude = 37.6173;

  // Получаем API-ключ для Geoapify из переменных окружения
  String get _geoapifyApiKey => dotenv.env['GEOAPIFY_API_KEY'] ?? 'GEOAPIFY_API_KEY';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _barsBloc = BarsBloc.withDefaultDependencies()..add(const LoadBars());
  }

  @override
  void dispose() {
    _barsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _barsBloc,
      child: CupertinoPageScaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        navigationBar: CupertinoNavigationBar(
          backgroundColor: AppTheme.isDarkMode(context)
              ? AppTheme.darkCardColor.withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          middle: Text(
            'Discover Bars',
            style: AppTheme.titleStyle.copyWith(
              color: AppTheme.textColor(context),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  color: _showDistanceFilter
                      ? AppTheme.primaryColor
                      : AppTheme.textColor(context).withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _showDistanceFilter = !_showDistanceFilter;
                  });
                },
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.refresh,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () => _barsBloc.add(const RefreshBars()),
              ),
            ],
          ),
          // Делаем границу прозрачной для более плавного перехода к карте
          border: const Border(bottom: BorderSide(color: Colors.transparent)),
        ),
        child: BlocConsumer<BarsBloc, BarsState>(
          listener: (context, state) {
            if (state is BarDetailsLoaded) {
              _showBarDetails(context, state.bar);
            } else if (state is CheckInSuccess) {
              _showCheckInSuccess(context, state.barName);
            } else if (state is LocationServicesDisabled) {
              _showLocationServicesDisabledDialog(context);
            } else if (state is LocationPermissionDenied) {
              _showLocationPermissionDeniedDialog(context);
            }
          },
          builder: (context, state) {
            if (state is BarsLoading) {
              return Center(
                child: CupertinoActivityIndicator(
                  color: AppTheme.isDarkMode(context)
                      ? AppTheme.primaryColor
                      : AppTheme.primaryDarkColor,
                ),
              );
            } else if (state is BarsLoaded) {
              return state.bars.isEmpty
                  ? _buildEmptyState()
                  : _buildBarsContent(context, state.bars);
            } else if (state is BarsLoadedWithDistance) {
              return state.bars.isEmpty
                  ? _buildEmptyState()
                  : _buildBarsContent(context, state.bars);
            } else if (state is BarsError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.errorColor(context),
                  ),
                ),
              );
            }
            return Center(
              child: CupertinoActivityIndicator(
                color: AppTheme.isDarkMode(context)
                    ? AppTheme.primaryColor
                    : AppTheme.primaryDarkColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBarsContent(BuildContext context, List<Bar> bars) {
    if (_showDistanceFilter) {
      return Column(
        children: [
          DistanceFilterWidget(
            currentDistance: _currentMaxDistance,
            isVisible: true,
            onDistanceChanged: (distance) {
              setState(() {
                _currentMaxDistance = distance;
              });
              _barsBloc.add(UpdateDistanceFilter(distance));
            },
          ),
          Expanded(child: _buildBarsMap(context, bars)),
        ],
      );
    } else {
      // Если фильтр скрыт, просто отображаем карту без обертки в Column
      return _buildBarsMap(context, bars);
    }
  }

  Widget _buildBarsMap(BuildContext context, List<Bar> bars) {
    if (bars.isEmpty) {
      return _buildEmptyState();
    }

    // Определяем центр карты по первому бару или используем значения по умолчанию
    final centerLat = bars.isNotEmpty ? bars[0].latitude : _defaultLatitude;
    final centerLng = bars.isNotEmpty ? bars[0].longitude : _defaultLongitude;
    final center = LatLng(centerLat, centerLng);

    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    final navBarHeight = CupertinoNavigationBar().preferredSize.height;

    return Stack(
      children: [
        // Карта на весь экран
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              onTap: (_, point) {
                // Закрываем всплывающее окно при нажатии на карту
                setState(() {
                  _selectedBar = null;
                });
              },
            ),
            children: [
              // Слой карты (тайлы)
              TileLayer(
                urlTemplate: 'https://api.geoapify.com/v1/tile/klokantech-basic/{z}/{x}/{y}.png?apiKey={apiKey}',
                additionalOptions: {
                  'apiKey': _geoapifyApiKey,
                },
                userAgentPackageName: 'sipswipe',
              ),
              // Слой маркеров баров
              MarkerLayer(
                markers: _buildBarMarkers(context, bars),
              ),
              // Показываем всплывающее окно для выбранного бара
              if (_selectedBar != null) _buildBarPopupOverlay(context, _selectedBar!),
            ],
          ),
        ),

        // Кнопки действий перемещены вверх
        Positioned(
          top: navBarHeight + statusBarHeight + 10,
          right: 10,
          child: Column(
            children: [
              _buildActionButton(
                icon: CupertinoIcons.location_fill,
                color: AppTheme.primaryColor,
                onTap: () => _centerMapOnUserLocation(),
              ),
              const SizedBox(height: 10),
              _buildActionButton(
                icon: CupertinoIcons.search,
                color: AppTheme.secondaryColor(context),
                onTap: () => _showSearchBarDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Создаем маркеры для всех баров
  List<Marker> _buildBarMarkers(BuildContext context, List<Bar> bars) {
    return bars.map((bar) {
      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(bar.latitude, bar.longitude),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedBar = bar;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: _selectedBar?.id == bar.id
                  ? AppTheme.primaryColor
                  : AppTheme.secondaryColor(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.sports_bar,  // Заменяем на Material-иконку, т.к. в CupertinoIcons нет beer
                color: Colors.white,
                size: 20.0,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // Создаем всплывающее окно для выбранного бара
  Widget _buildBarPopupOverlay(BuildContext context, Bar bar) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 120, // Размещаем над кнопками
      child: GestureDetector(
        onTap: () => _barsBloc.add(ViewBarDetails(bar.id)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bar.name,
                      style: AppTheme.subtitleStyle.copyWith(
                        color: AppTheme.textColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${bar.distance.toStringAsFixed(1)} km',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (bar.beerTypes.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: bar.beerTypes.take(3).map((type) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor(context).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type,
                      style: AppTheme.smallText.copyWith(
                        color: AppTheme.secondaryColor(context),
                      ),
                    ),
                  )).toList(),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Уровень загруженности
                  Row(
                    children: [
                      Icon(
                        _getCrowdLevelIcon(bar.crowdLevel ?? 'unknown'),
                        size: 16,
                        color: _getCrowdLevelColor(bar.crowdLevel ?? 'unknown', context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bar.crowdLevel ?? 'unknown',
                        style: AppTheme.smallText.copyWith(
                          color: AppTheme.secondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  // Количество людей, направляющихся в бар
                  if (bar.plannedVisitorsCount != null && bar.plannedVisitorsCount! > 0)
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.person_2_fill,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${bar.plannedVisitorsCount} heading',
                          style: AppTheme.smallText.copyWith(
                            color: AppTheme.secondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Кнопка "Дизлайк"
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.xmark,
                            size: 16,
                            color: AppTheme.errorColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Skip',
                            style: AppTheme.smallText.copyWith(
                              color: AppTheme.errorColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      _barsBloc.add(DislikeBar(bar.id));
                      setState(() {
                        _selectedBar = null;
                      });
                    },
                  ),
                  // Кнопка "Лайк"
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.heart,
                            size: 16,
                            color: AppTheme.successColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Like',
                            style: AppTheme.smallText.copyWith(
                              color: AppTheme.successColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      _barsBloc.add(LikeBar(bar.id));
                      setState(() {
                        _selectedBar = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCrowdLevelIcon(String crowdLevel) {
    switch (crowdLevel.toLowerCase()) {
      case 'low':
        return CupertinoIcons.person;
      case 'medium':
        return CupertinoIcons.person_2;
      case 'high':
        return CupertinoIcons.person_3;
      default:
        return CupertinoIcons.person_2;
    }
  }

  // Получаем цвет для уровня загруженности
  Color _getCrowdLevelColor(String crowdLevel, BuildContext context) {
    switch (crowdLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return AppTheme.secondaryTextColor(context);
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  // Центрирование карты на текущем местоположении пользователя
  void _centerMapOnUserLocation() {
    // Запрос на обновление местоположения через BarsBloc
    _barsBloc.add(const RefreshUserLocation());
  }

  // Диалог поиска бара
  void _showSearchBarDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Bars',
              style: AppTheme.titleStyle.copyWith(
                color: AppTheme.textColor(context),
              ),
            ),
            const SizedBox(height: 16),
            CupertinoSearchTextField(
              placeholder: 'Enter bar name',
              style: TextStyle(color: AppTheme.textColor(context)),
              onSubmitted: (query) {
                // Здесь можно добавить логику поиска
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'Search functionality coming soon!',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.secondaryTextColor(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.map_fill,
            size: 80,
            color: AppTheme.primaryColor.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'No bars found nearby',
            style: AppTheme.titleStyle.copyWith(
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try expanding your search radius or check back later',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.secondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            color: AppTheme.primaryColor,
            onPressed: () => _barsBloc.add(const RefreshBars()),
            child: Text(
              'Refresh',
              style: AppTheme.buttonStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showBarDetails(BuildContext context, Bar bar) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => BarDetailScreen(
          bar: bar,
          onCheckIn: () {
            _barsBloc.add(CheckInBar(bar.id));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showCheckInSuccess(BuildContext context, String barName) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Check-in Successful',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'You have checked in to $barName',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showLocationServicesDisabledDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Location Services Disabled',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'Please enable location services in your device settings to see bars near you.',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showLocationPermissionDeniedDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Location Permission Denied',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        content: Text(
          'Please grant location permission to see bars near you.',
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textColor(context),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: AppTheme.buttonStyle.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
