import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../IO/localizationIO.dart';
import '../globals.dart' as globals;
import '../theme.dart' as theme;
import 'Filter.dart';
import 'SwatchList.dart';

class SwatchFilterDrawer extends StatefulWidget {
  final void Function(List<Filter>) onDrawerClose;

  final GlobalKey? swatchListKey;

  SwatchFilterDrawer({ Key? key, required this.onDrawerClose, this.swatchListKey }) : super(key: key);

  @override
  SwatchFilterDrawerState createState() => SwatchFilterDrawerState();
}

class SwatchFilterDrawerState extends State<SwatchFilterDrawer> {
  static const List<String> _finishes = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];
  static const int _minRating = 1;
  static const int _maxRating = 10;
  static const double _minWeight = 0;
  static const double _maxWeight = 100;
  static const double _minPrice = 0;
  static const double _maxPrice = 100;

  List<Filter<String>> _finishesFilters = [];
  Filter<String> _brandFilter = Filter(FilterType.EqualTo, 'brand', '');
  Filter<String> _paletteFilter = Filter(FilterType.EqualTo, 'palette', '');
  Filter<int> _minRatingFilter = Filter(FilterType.GreaterThanOrEqualTo, 'rating', _minRating);
  Filter<int> _maxRatingFilter = Filter(FilterType.LessThanOrEqualTo, 'rating', _maxRating);
  List<Filter<String>> _tagsFilters = [];
  Filter<double> _minWeightFilter = Filter(FilterType.GreaterThanOrEqualTo, 'weight', _minWeight);
  Filter<double> _maxWeightFilter = Filter(FilterType.LessThanOrEqualTo, 'weight', _maxWeight);
  Filter<double> _minPriceFilter = Filter(FilterType.GreaterThanOrEqualTo, 'price', _minPrice);
  Filter<double> _maxPriceFilter = Filter(FilterType.LessThanOrEqualTo, 'price', _maxPrice);

  RangeValues _ratingValues = RangeValues(_minRating.toDouble(), _maxRating.toDouble());
  List<String> _selectedTags = [];
  List<String> _selectedFinishes = _finishes.toList();

  TextEditingController _minWeightController = TextEditingController();
  TextEditingController _maxWeightController = TextEditingController();
  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SwatchListState? state;
    if(widget.swatchListKey != null) {
      state = (widget.swatchListKey!.currentState as SwatchListState);
    }
    if(state != null && state.filters.length > 0) {
      loadFilters(state.filters);
    } else {
      resetFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 55, 22, 170),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('${getString('filter_filterBy')}', style: theme.primaryTextBold),
                TextButton(
                  onPressed: () {
                    resetFilters();
                    setState(() { });
                  },
                  child: Text(
                    '${getString('filter_clear')}',
                    style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.tertiaryTextSize, decoration: TextDecoration.underline,fontFamily: theme.fontFamily),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          getFinishField(context),
          getBrandField(context),
          getPaletteField(context),
          getRatingField(context),
          getTagsField(context),
          getWeightField(context),
          getPriceField(context),
        ],
      ),
    );
  }

  Widget getField(String label, Widget child) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              '$label: ',
              style: theme.primaryTextPrimary,
              textAlign: TextAlign.left,
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget getFinishField(BuildContext context) {
    List<Widget> widgets = [];
    for(int i = 0; i < _finishes.length; i++) {
      if(_finishes[i] == '') {
        continue;
      }
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text('${getString(_finishes[i])}', style: theme.primaryTextSecondary),
          selected: _selectedFinishes.contains(_finishes[i]),
          onSelected: (bool selected) {
            setState(() {
              if(selected) {
                _selectedFinishes.add(_finishes[i]);
                for(int j = 0; j < _finishesFilters.length; j++) {
                  if(_finishesFilters[j].threshold == _finishes[i]) {
                    _finishesFilters.removeAt(j);
                    break;
                  }
                }
              } else {
                _selectedFinishes.remove(_finishes[i]);
                _finishesFilters.add(Filter(FilterType.NotEqualTo, 'finish', _finishes[i]));
              }
            });
            //widget.onChange(filters);
          },
        ),
      );
      widgets.add(
        const SizedBox(
          width: 10,
        ),
      );
    }
    return getField(
      '${getString('swatch_finish')}',
      Container(
        alignment: Alignment.center,
        child: Wrap(
          children: widgets,
        ),
      ),
    );
  }

  Widget getBrandField(BuildContext context) {
    return getField(
      '${getString('swatch_brand')}',
      TextField(
        scrollPadding: EdgeInsets.zero,
        style: theme.primaryTextPrimary,
        controller: TextEditingController()..text = _brandFilter.threshold,
        textAlign: TextAlign.left,
        textInputAction: TextInputAction.done,
        onChanged: (String val) {
          _brandFilter.threshold = val;
          //widget.onChange(filters);
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.primaryColorDark,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.accentColor,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget getPaletteField(BuildContext context) {
    return getField(
      '${getString('swatch_palette')}',
      TextField(
        scrollPadding: EdgeInsets.zero,
        style: theme.primaryTextPrimary,
        controller: TextEditingController()..text = _paletteFilter.threshold,
        textAlign: TextAlign.left,
        textInputAction: TextInputAction.done,
        onChanged: (String val) {
          _paletteFilter.threshold = val;
          //widget.onChange(filters);
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.primaryColorDark,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.accentColor,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget getRatingField(BuildContext context) {
    return getField(
      '${getString('swatch_rating')}: ${_ratingValues.start.round().toString()} - ${_ratingValues.end.round().toString()}',
      Container(
        height: 50,
        child: RangeSlider(
          values: _ratingValues,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: theme.accentColor,
          inactiveColor: theme.primaryColorDark,
          labels: RangeLabels(
            _ratingValues.start.round().toString(),
            _ratingValues.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _ratingValues = values;
              _minRatingFilter.threshold = _ratingValues.start.round();
              _maxRatingFilter.threshold = _ratingValues.end.round();
              //widget.onChange(filters);
            });
          },
        ),
      ),
    );
  }

  Widget getTagsField(BuildContext context) {
    List<String> tags = globals.tags;
    List<Widget> widgets = [];
    for(int i = 0; i < tags.length; i++) {
      if(tags[i] == '') {
        continue;
      }
      String text = tags[i];
      if(text.contains('_')) {
        text = getString(text);
      }
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text(text, style: theme.primaryTextSecondary),
          selected: _selectedTags.contains(tags[i]),
          onSelected: (bool selected) {
            setState(() {
              if(selected) {
                _selectedTags.add(tags[i]);
                _tagsFilters.add(Filter(FilterType.ContainedIn, 'tags', tags[i]));
              } else {
                _selectedTags.remove(tags[i]);
                for(int j = 0; j < _tagsFilters.length; j++) {
                  if(_tagsFilters[j].threshold == tags[i]) {
                    _tagsFilters.removeAt(j);
                    break;
                  }
                }
              }
            });
            //widget.onChange(filters);
          },
        ),
      );
      widgets.add(
        const SizedBox(
          width: 10,
        ),
      );
    }
    return getField(
      '${getString('swatch_tags')}',
      Container(
        alignment: Alignment.center,
        child: Wrap(
          children: widgets,
        ),
      ),
    );
  }

  Widget getWeightField(BuildContext context) {
    TextSelection selection = _minWeightController.selection;
    _minWeightController.text = _minWeightFilter.threshold.toString();
    try {
      _minWeightController.selection = selection;
    } catch(e) {
      //just ignore it
    }

    selection = _maxWeightController.selection;
    _maxWeightController.text = _maxWeightFilter.threshold.toString();
    try {
      _maxWeightController.selection = selection;
    } catch(e) {
      //just ignore it
    }

    return getField(
      '${getString('swatch_weight')}',
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              scrollPadding: EdgeInsets.zero,
              style: theme.primaryTextPrimary,
              controller: _minWeightController,
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.done,
              onChanged: (String val) {
                double minWeight = double.parse(val);
                if(minWeight < _minWeight) {
                  minWeight = _minWeight;
                }
                if(minWeight > _maxWeightFilter.threshold) {
                  minWeight = _maxWeightFilter.threshold;
                }
                _minWeightFilter.threshold = minWeight;
                //widget.onChange(filters);
              },
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.primaryColorDark,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.accentColor,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
          Text('   -   ', style: theme.primaryTextBold),
          Expanded(
            child: TextField(
              scrollPadding: EdgeInsets.zero,
              style: theme.primaryTextPrimary,
              controller: _maxWeightController,
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.done,
              onChanged: (String val) {
                double maxWeight = double.parse(val);
                if(maxWeight < _minWeightFilter.threshold) {
                  maxWeight = _minWeightFilter.threshold;
                }
                _maxWeightFilter.threshold = maxWeight;
                //widget.onChange(filters);
              },
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.primaryColorDark,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.accentColor,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPriceField(BuildContext context) {
    TextSelection selection = _minPriceController.selection;
    _minPriceController.text = _minPriceFilter.threshold.toString();
    try {
      _minPriceController.selection = selection;
    } catch(e) {
    //just ignore it
    }

    selection = _maxPriceController.selection;
    _maxPriceController.text = _maxPriceFilter.threshold.toString();
    try {
      _maxPriceController.selection = selection;
    } catch(e) {
    //just ignore it
    }

    return getField(
      '${getString('swatch_price')}',
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              scrollPadding: EdgeInsets.zero,
              style: theme.primaryTextPrimary,
              controller: _minPriceController,
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.done,
              onChanged: (String val) {
                double minPrice = double.parse(val);
                if(minPrice < _minPrice) {
                  minPrice = _minPrice;
                }
                if(minPrice > _maxPriceFilter.threshold) {
                  minPrice = _maxPriceFilter.threshold;
                }
                _minPriceFilter.threshold = minPrice;
                //widget.onChange(filters);
              },
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.primaryColorDark,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.accentColor,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
          Text('   -   ', style: theme.primaryTextBold),
          Expanded(
            child: TextField(
              scrollPadding: EdgeInsets.zero,
              style: theme.primaryTextPrimary,
              controller: _maxPriceController,
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.done,
              onChanged: (String val) {
                double maxPrice = double.parse(val);
                if(maxPrice < _minPriceFilter.threshold) {
                  maxPrice = _minPriceFilter.threshold;
                }
                _maxPriceFilter.threshold = maxPrice;
                //widget.onChange(filters);
              },
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
              ],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.primaryColorDark,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                  borderSide: BorderSide(
                    color: theme.accentColor,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Filter> getFilters() {
    List<Filter> ret = [];
    ret.addAll(_finishesFilters);
    if(_brandFilter.threshold.trim() != '') {
      _brandFilter.threshold = _brandFilter.threshold.trim();
      ret.add(_brandFilter);
    }
    if(_paletteFilter.threshold.trim() != '') {
      _paletteFilter.threshold = _paletteFilter.threshold.trim();
      ret.add(_paletteFilter);
    }
    if(_minRatingFilter.threshold != _minRating) {
      ret.add(_minRatingFilter);
    }
    if(_maxRatingFilter.threshold != _maxRating) {
      ret.add(_maxRatingFilter);
    }
    ret.addAll(_tagsFilters);
    if(_minWeightFilter.threshold != _minWeight) {
      ret.add(_minWeightFilter);
    }
    if(_maxWeightFilter.threshold != _maxWeight) {
      ret.add(_maxWeightFilter);
    }
    if(_minPriceFilter.threshold != _minPrice) {
      ret.add(_minPriceFilter);
    }
    if(_maxPriceFilter.threshold != _maxPrice) {
      ret.add(_maxPriceFilter);
    }
    return ret;
  }

  @override
  void dispose() {
    super.dispose();
    widget.onDrawerClose(getFilters());
  }

  void loadFilters(List<Filter> filters) {
    resetFilters();
    for(int i = 0; i < filters.length; i++) {
      switch(filters[i].attribute) {
        case 'finish': {
          _selectedFinishes.remove(filters[i].threshold);
          _finishesFilters.add(Filter(FilterType.NotEqualTo, 'finish', filters[i].threshold));
          break;
        }
        case 'brand': {
          _brandFilter.threshold = filters[i].threshold;
          break;
        }
        case 'palette': {
          _paletteFilter.threshold = filters[i].threshold;
          break;
        }
        case 'rating': {
          if(filters[i].type == _minRatingFilter.type) {
            _ratingValues = RangeValues(double.parse(filters[i].threshold.toString()), _ratingValues.end);
            _minRatingFilter.threshold = filters[i].threshold;
          } else {
            _ratingValues = RangeValues(_ratingValues.start, double.parse(filters[i].threshold.toString()));
            _maxRatingFilter.threshold = filters[i].threshold;
          }
          break;
        }
        case 'tags': {
          _selectedTags.add(filters[i].threshold);
          _tagsFilters.add(Filter(FilterType.ContainedIn, 'tags', filters[i].threshold));
          break;
        }
        case 'weight': {
          if(filters[i].type == _minWeightFilter.type) {
            _minWeightFilter.threshold = filters[i].threshold;
          } else {
            _maxWeightFilter.threshold = filters[i].threshold;
          }
          break;
        }
        case 'price': {
          if(filters[i].type == _minPriceFilter.type) {
            _minPriceFilter.threshold = filters[i].threshold;
          } else {
            _maxPriceFilter.threshold = filters[i].threshold;
          }
          break;
        }
      }
    }
  }

  void resetFilters() {
    _ratingValues = RangeValues(_minRating.toDouble(), _maxRating.toDouble());
    _selectedTags = [];
    _selectedFinishes = _finishes.toList();

    _finishesFilters = [];
    _brandFilter.threshold = '';
    _paletteFilter.threshold = '';
    _minRatingFilter.threshold = _minRating;
    _maxRatingFilter.threshold = _maxRating;
    _tagsFilters = [];
    _minWeightFilter.threshold = _minWeight;
    _maxWeightFilter.threshold = _maxWeight;
    _minPriceFilter.threshold = _minPrice;
    _maxPriceFilter.threshold = _maxPrice;
  }
}