import 'ColorObjects.dart';
import 'ColorDifferences.dart';
import 'ColorConversions.dart';
import '../Widgets/Swatch.dart';

Map<String, RGBColor> colorWheel;
Map<String, List<String>> similarColorNames;
Map<String, List<String>> oppositeColorNames;

Map<String, RGBColor> createColorWheel() {
  if(colorWheel == null) {
    colorWheel = Map<String, RGBColor>();
    colorWheel['color_pastelRed'] = RGBColor(1, 0.95, 0.95);
    colorWheel['color_nude'] = RGBColor(0.920, 0.804, 0.745);
    colorWheel['color_lightRed'] = RGBColor(1, 0.8, 0.8);
    colorWheel['color_red'] = RGBColor(0.9, 0.3, 0.3);
    colorWheel['color_darkRed'] = RGBColor(0.2, 0, 0);
    colorWheel['color_burgundy'] = RGBColor(0.322, 0, 0.078);
    colorWheel['color_pastelOrange'] = RGBColor(1, 0.95, 0.85);
    colorWheel['color_peach'] = RGBColor(1, 0.882, 0.741);
    colorWheel['color_lightOrange'] = RGBColor(1, 0.8, 0.6);
    colorWheel['color_orange'] = RGBColor(1, 0.5, 0.1);
    colorWheel['color_darkOrange'] = RGBColor(0.2, 0.1, 0);
    colorWheel['color_lightBrown'] = RGBColor(0.851, 0.654, 0.494);
    colorWheel['color_beige'] = RGBColor(0.761, 0.551, 0.471);
    colorWheel['color_taupe'] = RGBColor(0.529, 0.475, 0.427);
    colorWheel['color_tan'] = RGBColor(0.859, 0.600, 0.318);
    colorWheel['color_brown'] = RGBColor(0.565, 0.350, 0.212);
    colorWheel['color_rust'] = RGBColor(0.600, 0.220, 0.114);
    colorWheel['color_darkBeige'] = RGBColor(0.388, 0.322, 0.240);
    colorWheel['color_darkBrown'] = RGBColor(0.169, 0.114, 0.063);
    colorWheel['color_chocolate'] = RGBColor(0.251, 0.102, 0.039);
    colorWheel['color_pastelYellow'] = RGBColor(1, 1, 0.9);
    colorWheel['color_cream'] = RGBColor(1, 0.959, 0.851);
    colorWheel['color_lightYellow'] = RGBColor(1, 1, 0.6);
    colorWheel['color_yellow'] = RGBColor(0.9, 0.9, 0.1);
    colorWheel['color_lightChartreuse'] = RGBColor(0.9, 1, 0.8);
    colorWheel['color_chartreuse'] = RGBColor(0.5, 0.9, 0.1);
    colorWheel['color_darkChartreuse'] = RGBColor(0.1, 0.2, 0);
    colorWheel['color_pastelGreen'] = RGBColor(0.95, 1, 0.95);
    colorWheel['color_lightGreen'] = RGBColor(0.8, 1, 0.8);
    colorWheel['color_green'] = RGBColor(0.1, 0.9, 0.1);
    colorWheel['color_darkGreen'] = RGBColor(0, 0.2, 0);
    colorWheel['color_pastelMint'] = RGBColor(0.95, 1, 0.95);
    colorWheel['color_mint'] = RGBColor(0.8, 1, 0.9);
    colorWheel['color_aquamarine'] = RGBColor(0.2, 0.9, 0.5);
    colorWheel['color_darkAquamarine'] = RGBColor(0, 0.2, 0.1);
    colorWheel['color_pastelTurquoise'] = RGBColor(0.9, 1, 1);
    colorWheel['color_lightTurquoise'] = RGBColor(0.8, 1, 1);
    colorWheel['color_turquoise'] = RGBColor(0.4, 0.9, 0.9);
    colorWheel['color_darkTurquoise'] = RGBColor(0, 0.2, 0.2);
    colorWheel['color_lightSkyBlue'] = RGBColor(0.8, 0.9, 1);
    colorWheel['color_skyBlue'] = RGBColor(0.2, 0.5, 0.9);
    colorWheel['color_darkSkyBlue'] = RGBColor(0, 0.1, 0.2);
    colorWheel['color_pastelBlue'] = RGBColor(0.9, 0.95, 1);
    colorWheel['color_lightBlue'] = RGBColor(0.8, 0.8, 1);
    colorWheel['color_blue'] = RGBColor(0.1, 0.1, 0.9);
    colorWheel['color_darkBlue'] = RGBColor(0, 0, 0.2);
    colorWheel['color_pastelLavender'] = RGBColor(0.95, 0.9, 1);
    colorWheel['color_lavender'] = RGBColor(0.9, 0.8, 1);
    colorWheel['color_indigo'] = RGBColor(0.5, 0, 1);
    colorWheel['color_darkIndigo'] = RGBColor(0.1, 0, 0.2);
    colorWheel['color_lightPurple'] = RGBColor(1, 0.8, 1);
    colorWheel['color_purple'] = RGBColor(0.9, 0.1, 0.9);
    colorWheel['color_darkPurple'] = RGBColor(0.2, 0, 0.2);
    colorWheel['color_mauve'] = RGBColor(0.8, 0.6, 0.7);
    colorWheel['color_violet'] = RGBColor(0.9, 0.3, 0.9);
    colorWheel['color_darkViolet'] = RGBColor(0.15, 0, 0.15);
    colorWheel['color_pastelPink'] = RGBColor(1, 0.9, 0.95);
    colorWheel['color_lightPink'] = RGBColor(1, 0.8, 0.9);
    colorWheel['color_pink'] = RGBColor(0.9, 0.1, 0.5);
    colorWheel['color_darkPink'] = RGBColor(0.2, 0, 0.1);
    colorWheel['color_white'] = RGBColor(1, 1, 1);
    colorWheel['color_lightGray'] = RGBColor(0.25, 0.25, 0.25);
    colorWheel['color_gray'] = RGBColor(0.5, 0.5, 0.5);
    colorWheel['color_darkGray'] = RGBColor(0.75, 0.75, 0.75);
    colorWheel['color_darkTaupe'] = RGBColor(0.271, 0.247, 0.227);
    colorWheel['color_black'] = RGBColor(0, 0, 0);
  }
  return colorWheel;
}

Map<String, List<String>> createSimilarColorNames() {
  if(similarColorNames == null) {
    similarColorNames = Map<String, List<String>>();
    similarColorNames['color_white'] = ['color_lightGray', 'color_gray', 'color_darkGray', 'color_black', 'color_cream', 'color_pastelRed', 'color_pastelOrange', 'color_pastelYellow', 'color_pastelGreen', 'color_pastelMint', 'color_pastelTurquoise', 'color_pastelBlue', 'color_pastelLavender', 'color_pastelPink'];
    similarColorNames['color_lightGray'] = ['color_white', 'color_gray', 'color_darkGray', 'color_black'];
    similarColorNames['color_gray'] = ['color_white', 'color_lightGray', 'color_darkGray', 'color_black', 'color_taupe'];
    similarColorNames['color_darkGray'] = ['color_white', 'color_lightGray', 'color_gray', 'color_black', 'color_darkTaupe'];
    similarColorNames['color_black'] = ['color_white', 'color_lightGray', 'color_gray', 'color_darkGray'];
    similarColorNames['color_lightBrown'] = ['color_brown', 'color_darkBrown', 'color_beige', 'color_chocolate', 'color_lightOrange', 'color_orange', 'color_lightRed', 'color_red'];
    similarColorNames['color_brown'] = ['color_lightBrown', 'color_darkBrown', 'color_beige', 'color_darkBeige', 'color_chocolate', 'color_lightOrange', 'color_orange', 'color_darkOrange', 'color_lightRed', 'color_red', 'color_darkRed', 'color_burgundy'];
    similarColorNames['color_darkBrown'] = ['color_lightBrown', 'color_brown', 'color_beige', 'color_darkBeige', 'color_chocolate', 'color_lightOrange', 'color_orange', 'color_darkOrange', 'color_lightRed', 'color_red', 'color_darkRed', 'color_burgundy'];
    similarColorNames['color_beige'] = ['color_darkBeige', 'color_lightBrown', 'color_brown', 'color_darkBrown', 'color_lightOrange', 'color_orange', 'color_darkOrange'];
    similarColorNames['color_darkBeige'] = ['color_beige', 'color_brown', 'color_darkBrown', 'color_lightOrange', 'color_orange', 'color_darkOrange'];
    similarColorNames['color_taupe'] = ['color_darkTaupe', 'color_darkBrown', 'color_white', 'color_lightGray', 'color_black'];
    similarColorNames['color_darkTaupe'] = ['color_taupe', 'color_darkBrown', 'color_white', 'color_lightGray', 'color_black'];
    similarColorNames['color_nude'] = ['color_beige', 'color_darkBeige', 'color_chocolate', 'color_lightBrown', 'color_darkBrown', 'color_lightOrange', 'color_orange', 'color_darkOrange'];
    similarColorNames['color_cream'] = ['color_white', 'color_pastelYellow', 'color_yellow', 'color_taupe', 'color_darkTaupe'];
    similarColorNames['color_peach'] = ['color_lightBrown', 'color_brown', 'color_darkBrown', 'color_chocolate', 'color_tan', 'color_lightOrange', 'color_orange', 'color_darkOrange'];
    similarColorNames['color_tan'] = ['color_lightBrown', 'color_brown', 'color_darkBrown', 'color_peach', 'color_lightOrange', 'color_orange', 'color_darkOrange', 'color_yellow'];
    similarColorNames['color_rust'] = ['color_lightBrown', 'color_brown', 'color_darkBrown', 'color_beige', 'color_darkBeige', 'color_chocolate', 'color_lightRed', 'color_red'];
    similarColorNames['color_chocolate'] = ['color_nude', 'color_lightBrown', 'color_brown', 'color_darkBrown', 'color_beige', 'color_darkBeige', 'color_rust', 'color_red', 'color_darkRed', 'color_burgundy'];
    similarColorNames['color_pastelRed'] = ['color_white', 'color_lightRed', 'color_red', 'color_darkRed', 'color_burgundy', 'color_pastelOrange', 'color_pastelPink', 'color_pastelLavender'];
    similarColorNames['color_lightRed'] = ['color_pastelRed', 'color_red', 'color_darkRed', 'color_burgundy', 'color_lightOrange', 'color_lightPink', 'color_mauve'];
    similarColorNames['color_red'] = ['color_pastelRed', 'color_lightRed', 'color_darkRed', 'color_rust', 'color_burgundy', 'color_orange', 'color_pink', 'color_violet'];
    similarColorNames['color_darkRed'] = ['color_pastelRed', 'color_lightRed', 'color_red', 'color_burgundy', 'color_darkOrange', 'color_darkPink', 'color_darkViolet'];
    similarColorNames['color_burgundy'] = ['color_pastelRed', 'color_lightRed', 'color_red', 'color_darkRed', 'color_darkOrange', 'color_darkPink', 'color_darkViolet', 'color_darkPurple'];
    similarColorNames['color_pastelOrange'] = ['color_white', 'color_lightOrange', 'color_orange', 'color_darkOrange', 'color_pastelRed', 'color_pastelYellow'];
    similarColorNames['color_lightOrange'] = ['color_pastelOrange', 'color_orange', 'color_darkOrange', 'color_lightRed', 'color_lightYellow'];
    similarColorNames['color_orange'] = ['color_pastelOrange', 'color_lightOrange', 'color_darkOrange', 'color_red', 'color_yellow'];
    similarColorNames['color_darkOrange'] = ['color_pastelOrange', 'color_lightOrange', 'color_orange', 'color_darkRed', 'color_burgundy'];
    similarColorNames['color_pastelYellow'] = ['color_white', 'color_lightYellow', 'color_yellow', 'color_pastelGreen', 'color_pastelMint', 'color_pastelOrange'];
    similarColorNames['color_lightYellow'] = ['color_pastelYellow', 'color_yellow', 'color_lightChartreuse', 'color_lightGreen', 'color_lightOrange'];
    similarColorNames['color_yellow'] = ['color_pastelYellow', 'color_lightYellow', 'color_chartreuse', 'color_green', 'color_orange'];
    similarColorNames['color_lightChartreuse'] = ['color_pastelGreen', 'color_pastelYellow', 'color_chartreuse', 'color_darkChartreuse', 'light color_aquamarine', 'color_lightGreen', 'color_lightYellow'];
    similarColorNames['color_chartreuse'] = ['color_pastelGreen', 'color_pastelYellow', 'color_lightChartreuse', 'color_darkChartreuse', 'color_aquamarine', 'color_green', 'color_yellow'];
    similarColorNames['color_darkChartreuse'] = ['color_pastelGreen', 'color_pastelYellow', 'color_lightChartreuse', 'color_chartreuse', 'color_darkAquamarine', 'color_darkGreen', 'dark color_yellow'];
    similarColorNames['color_pastelGreen'] = ['color_white', 'color_lightGreen', 'color_green', 'color_darkGreen', 'color_pastelMint', 'color_pastelTurquoise', 'color_pastelYellow'];
    similarColorNames['color_lightGreen'] = ['color_pastelGreen', 'color_green', 'color_darkGreen', 'color_mint', 'color_lightTurquoise', 'color_lightChartreuse', 'color_lightYellow'];
    similarColorNames['color_green'] = ['color_pastelGreen', 'color_lightGreen', 'color_darkGreen', 'color_aquamarine', 'color_turquoise', 'color_chartreuse', 'color_yellow'];
    similarColorNames['color_darkGreen'] = ['color_pastelGreen', 'color_lightGreen', 'color_green', 'color_darkAquamarine', 'color_darkTurquoise', 'color_darkChartreuse'];
    similarColorNames['color_pastelMint'] = ['color_white', 'color_mint', 'color_aquamarine', 'color_aquamarine', 'color_pastelBlue', 'color_pastelTurquoise', 'color_pastelGreen'];
    similarColorNames['color_mint'] = ['color_pastelMint', 'color_aquamarine', 'color_darkAquamarine', 'color_lightSkyBlue', 'color_lightTurquoise', 'color_lightGreen'];
    similarColorNames['color_aquamarine'] = ['color_pastelMint', 'color_mint', 'color_darkAquamarine', 'color_skyBlue', 'color_turquoise', 'color_green'];
    similarColorNames['color_darkAquamarine'] = ['color_pastelMint', 'color_mint', 'color_aquamarine', 'color_darkSkyBlue', 'color_darkTurquoise', 'color_darkGreen'];
    similarColorNames['color_pastelTurquoise'] = ['color_white', 'color_lightTurquoise', 'color_turquoise', 'color_darkTurquoise', 'color_pastelBlue', 'color_pastelGreen', 'color_pastelMint'];
    similarColorNames['color_lightTurquoise'] = ['color_pastelTurquoise', 'color_turquoise', 'color_darkTurquoise', 'color_lightBlue', 'color_lightSkyBlue', 'color_lightGreen', 'color_mint'];
    similarColorNames['color_turquoise'] = ['color_pastelTurquoise', 'color_lightTurquoise', 'color_darkTurquoise', 'color_blue', 'color_skyBlue', 'color_green', 'color_aquamarine'];
    similarColorNames['color_darkTurquoise'] = ['color_pastelTurquoise', 'color_lightTurquoise', 'color_turquoise', 'color_darkBlue', 'color_darkSkyBlue', 'color_darkGreen', 'color_darkAquamarine'];
    similarColorNames['color_lightSkyBlue'] = ['color_pastelBlue', 'color_skyBlue', 'color_darkSkyBlue', 'color_lightBlue', 'color_lavender', 'color_lightTurquoise', 'color_mint'];
    similarColorNames['color_skyBlue'] = ['color_pastelBlue', 'color_lightSkyBlue', 'color_darkSkyBlue', 'color_blue', 'color_indigo', 'color_turquoise', 'color_aquamarine'];
    similarColorNames['color_darkSkyBlue'] = ['color_pastelBlue', 'color_lightSkyBlue', 'color_skyBlue', 'color_darkBlue', 'color_darkIndigo', 'color_darkTurquoise', 'color_darkAquamarine'];
    similarColorNames['color_pastelBlue'] = ['color_white', 'color_lightBlue', 'color_blue', 'color_darkBlue', 'color_pastelLavender', 'color_pastelTurquoise'];
    similarColorNames['color_lightBlue'] = ['color_pastelBlue', 'color_blue', 'color_darkBlue', 'color_lightPurple', 'color_lavender', 'color_turquoise', 'color_skyBlue'];
    similarColorNames['color_blue'] = ['color_pastelBlue', 'color_lightBlue', 'color_darkBlue', 'color_purple', 'color_indigo', 'color_turquoise', 'color_skyBlue'];
    similarColorNames['color_darkBlue'] = ['color_pastelBlue', 'color_lightBlue', 'color_blue', 'color_darkPurple', 'color_darkIndigo', 'color_darkTurquoise', 'color_darkSkyBlue'];
    similarColorNames['color_pastelLavender'] = ['color_white', 'color_lavender', 'color_indigo', 'color_darkIndigo', 'color_pastelPink', 'color_pastelBlue'];
    similarColorNames['color_lavender'] = ['color_pastelLavender', 'color_indigo', 'color_darkIndigo', 'color_lightPurple', 'light color_violet', 'color_lightBlue', 'color_lightSkyBlue'];
    similarColorNames['color_indigo'] = ['color_pastelLavender', 'color_lavender', 'color_darkIndigo', 'color_purple', 'color_violet', 'color_blue', 'color_skyBlue'];
    similarColorNames['color_darkIndigo'] = ['color_pastelLavender', 'color_lavender', 'color_indigo', 'color_darkPurple', 'color_darkViolet', 'color_darkBlue', 'color_darkSkyBlue'];
    similarColorNames['color_lightPurple'] = ['color_pastelLavender', 'color_purple', 'color_darkPurple', 'color_lightPink', 'color_mauve', 'color_lavender', 'color_lightBlue'];
    similarColorNames['color_purple'] = ['color_pastelLavender', 'color_lightPurple', 'color_darkPurple', 'color_pink', 'color_violet', 'color_indigo', 'color_blue'];
    similarColorNames['color_darkPurple'] = ['color_pastelLavender', 'color_lightPurple', 'color_purple', 'color_darkPink', 'color_darkViolet', 'color_darkIndigo', 'color_darkBlue'];
    similarColorNames['color_mauve'] = ['color_pastelLavender', 'color_violet', 'color_darkViolet', 'color_lightPink', 'color_lightRed', 'color_lightPurple', 'color_lavender'];
    similarColorNames['color_violet'] = ['color_pastelLavender', 'color_mauve', 'color_darkViolet', 'color_pink', 'color_red', 'color_purple', 'color_indigo'];
    similarColorNames['color_darkViolet'] = ['color_pastelLavender', 'color_mauve', 'color_violet', 'color_darkPink', 'color_darkRed', 'color_burgundy', 'color_darkPurple', 'color_darkIndigo'];
    similarColorNames['color_pastelPink'] = ['color_white', 'color_lightPink', 'color_pink', 'color_darkPink', 'color_pastelRed', 'color_pastelLavender'];
    similarColorNames['color_lightPink'] = ['color_pastelPink', 'color_pink', 'color_darkPink', 'color_lightRed', 'color_mauve'];
    similarColorNames['color_pink'] = ['color_pastelPink', 'color_lightPink', 'color_darkPink', 'color_red', 'color_violet'];
    similarColorNames['color_darkPink'] = ['color_pastelPink', 'color_lightPink', 'color_pink', 'color_darkRed', 'color_burgundy', 'color_darkViolet'];
  }
  return similarColorNames;
}

Map<String, List<String>> createOppositeColorNames() {
  if(oppositeColorNames == null) {
    oppositeColorNames = Map<String, List<String>>();
    oppositeColorNames['color_white'] = [];
    oppositeColorNames['color_lightGray'] = [];
    oppositeColorNames['color_gray'] = [];
    oppositeColorNames['color_darkGray'] = [];
    oppositeColorNames['color_black'] = ['color_nude', 'color_cream', 'color_pastelRed', 'color_pastelOrange', 'color_pastelYellow', 'color_pastelGreen', 'color_pastelMint', 'color_pastelTurquoise', 'color_pastelBlue', 'color_pastelLavender', 'color_pastelPink'];
    oppositeColorNames['color_lightBrown'] = [];
    oppositeColorNames['color_brown'] = [];
    oppositeColorNames['color_darkBrown'] = [];
    oppositeColorNames['color_beige'] = [];
    oppositeColorNames['color_darkBeige'] = [];
    oppositeColorNames['color_taupe'] = [];
    oppositeColorNames['color_darkTaupe'] = [];
    oppositeColorNames['color_nude'] = [];
    oppositeColorNames['color_cream'] = [];
    oppositeColorNames['color_peach'] = [];
    oppositeColorNames['color_tan'] = [];
    oppositeColorNames['color_rust'] = [];
    oppositeColorNames['color_chocolate'] = [];
    oppositeColorNames['color_pastelRed'] = ['color_pastelBlue', 'color_pastelTurquoise', 'color_pastelMint', 'color_pastelGreen', 'color_black'];
    oppositeColorNames['color_lightRed'] = ['color_lightBlue', 'color_lightSkyBlue', 'color_lightTurquoise', 'color_mint', 'color_lightGreen', 'color_lightChartreuse'];
    oppositeColorNames['color_red'] = ['color_blue', 'color_skyBlue', 'color_turquoise', 'color_aquamarine', 'color_green', 'color_chartreuse'];
    oppositeColorNames['color_darkRed'] = ['color_darkBlue', 'color_darkSkyBlue', 'color_darkTurquoise', 'color_darkAquamarine', 'color_darkGreen', 'color_darkChartreuse'];
    oppositeColorNames['color_burgundy'] = ['color_darkBlue', 'color_darkSkyBlue', 'color_darkTurquoise', 'color_darkAquamarine', 'color_darkGreen', 'color_darkChartreuse'];
    oppositeColorNames['color_pastelOrange'] = ['color_pastelLavender', 'color_pastelBlue', 'color_pastelTurquoise', 'color_pastelMint', 'color_pastelGreen', 'color_black'];
    oppositeColorNames['color_lightOrange'] = ['color_lightPurple', 'color_lavender', 'color_lightBlue', 'color_lightSkyBlue', 'color_lightTurquoise', 'color_mint', 'color_lightGreen'];
    oppositeColorNames['color_orange'] = ['color_purple', 'color_indigo', 'color_blue', 'color_skyBlue', 'color_turquoise', 'color_aquamarine', 'color_green'];
    oppositeColorNames['color_darkOrange'] = ['color_darkPurple', 'color_darkIndigo', 'color_darkBlue', 'color_darkSkyBlue', 'color_darkTurquoise', 'color_darkAquamarine', 'color_darkGreen'];
    oppositeColorNames['color_pastelYellow'] = ['color_pastelPink', 'color_pastelLavender', 'color_pastelBlue', 'color_black'];
    oppositeColorNames['color_lightYellow'] = ['color_lightPink', 'color_mauve', 'color_lightPurple', 'color_lavender', 'color_lightBlue', 'color_lightSkyBlue'];
    oppositeColorNames['color_yellow'] = ['color_pink', 'color_darkPink', 'color_violet', 'color_darkViolet', 'color_purple', 'color_darkPurple', 'color_indigo', 'color_darkIndigo', 'color_blue', 'color_darkBlue', 'color_skyBlue', 'color_darkSkyBlue'];
    oppositeColorNames['color_lightChartreuse'] = ['color_lightRed', 'color_lightPink', 'color_mauve', 'color_purple', 'color_indigo'];
    oppositeColorNames['color_chartreuse'] = ['color_red', 'color_pink', 'color_violet', 'color_purple', 'color_indigo'];
    oppositeColorNames['color_darkChartreuse'] = ['color_darkRed', 'color_burgundy', 'color_darkPink', 'color_darkViolet', 'color_darkPurple', 'color_darkIndigo'];
    oppositeColorNames['color_pastelGreen'] = ['color_pastelOrange', 'color_pastelRed', 'color_pastelPink', 'color_pastelLavender', 'color_black'];
    oppositeColorNames['color_lightGreen'] = ['color_lightOrange', 'color_lightRed', 'color_lightPink', 'color_mauve', 'color_lightPurple'];
    oppositeColorNames['color_green'] = ['color_orange', 'color_red', 'color_pink', 'color_violet', 'color_purple'];
    oppositeColorNames['color_darkGreen'] = ['color_darkOrange', 'color_darkRed', 'color_burgundy', 'color_darkPink', 'color_darkViolet', 'color_darkPurple'];
    oppositeColorNames['color_pastelMint'] = ['color_pastelLavender', 'color_pastelPink', 'color_pastelRed', 'color_pastelOrange', 'color_black'];
    oppositeColorNames['color_mint'] = ['color_lightPurple', 'color_mauve', 'color_lightPink', 'color_lightRed', 'color_lightOrange'];
    oppositeColorNames['color_aquamarine'] = ['color_purple', 'color_violet', 'color_pink', 'color_red', 'color_orange'];
    oppositeColorNames['color_darkAquamarine'] = ['color_darkPurple', 'color_darkViolet', 'color_darkPink', 'color_darkRed', 'color_burgundy', 'color_darkOrange'];
    oppositeColorNames['color_pastelTurquoise'] = ['color_pastelPink', 'color_pastelRed', 'color_pastelOrange', 'color_black'];
    oppositeColorNames['color_lightTurquoise'] = ['color_lightPink', 'color_lightRed', 'color_lightOrange'];
    oppositeColorNames['color_turquoise'] = ['color_pink', 'color_red', 'color_orange'];
    oppositeColorNames['color_darkTurquoise'] = ['color_darkPink', 'color_darkRed', 'color_burgundy', 'color_darkOrange'];
    oppositeColorNames['color_lightSkyBlue'] = ['color_lightPink', 'color_lightRed', 'color_lightOrange', 'color_lightYellow'];
    oppositeColorNames['color_skyBlue'] = ['color_pink', 'color_red', 'color_orange', 'color_yellow'];
    oppositeColorNames['color_darkSkyBlue'] = ['color_darkPink', 'color_darkRed', 'color_burgundy', 'color_darkOrange', 'color_yellow'];
    oppositeColorNames['color_pastelBlue'] = ['color_pastelPink', 'color_pastelRed', 'color_pastelOrange', 'color_pastelYellow', 'color_black'];
    oppositeColorNames['color_lightBlue'] = ['color_lightPink', 'color_lightRed', 'color_lightOrange', 'color_lightYellow'];
    oppositeColorNames['color_blue'] = ['color_pink', 'color_red', 'color_orange', 'color_yellow'];
    oppositeColorNames['color_darkBlue'] = ['color_darkPink', 'color_darkRed', 'color_burgundy', 'color_darkOrange', 'color_yellow'];
    oppositeColorNames['color_pastelLavender'] = [ 'color_pastelOrange', 'color_pastelYellow', 'color_pastelGreen', 'color_pastelMint', 'color_black'];
    oppositeColorNames['color_lavender'] = ['color_lightOrange', 'color_lightYellow', 'color_lightChartreuse'];
    oppositeColorNames['color_indigo'] = ['color_orange', 'color_yellow', 'color_chartreuse'];
    oppositeColorNames['color_darkIndigo'] = ['color_darkOrange', 'color_yellow', 'color_darkChartreuse'];
    oppositeColorNames['color_lightPurple'] = ['color_lightOrange', 'color_lightYellow', 'color_lightChartreuse', 'color_lightGreen', 'color_mint'];
    oppositeColorNames['color_purple'] = ['color_orange', 'color_yellow', 'color_chartreuse', 'color_green', 'color_aquamarine'];
    oppositeColorNames['color_darkPurple'] = ['color_darkOrange', 'color_yellow', 'color_darkChartreuse', 'color_darkGreen', 'color_darkAquamarine'];
    oppositeColorNames['color_mauve'] = ['color_lightYellow', 'color_lightChartreuse', 'color_lightGreen', 'color_mint'];
    oppositeColorNames['color_violet'] = ['color_yellow', 'color_chartreuse', 'color_green', 'color_aquamarine'];
    oppositeColorNames['color_darkViolet'] = ['color_yellow', 'color_darkChartreuse', 'color_darkGreen', 'color_darkAquamarine'];
    oppositeColorNames['color_pastelPink'] = ['color_pastelBlue', 'color_pastelGreen', 'color_pastelGreen', 'color_pastelMint', 'color_pastelTurquoise', 'color_pastelBlue' 'color_black'];
    oppositeColorNames['color_lightPink'] = ['color_lightYellow', 'color_lightChartreuse', 'color_lightGreen', 'color_mint', 'color_lightTurquoise', 'color_lightBlue'];
    oppositeColorNames['color_pink'] = ['color_yellow', 'color_chartreuse', 'color_green', 'color_aquamarine', 'color_turquoise', 'color_blue'];
    oppositeColorNames['color_darkPink'] = ['color_yellow', 'color_darkChartreuse', 'color_darkGreen', 'color_darkAquamarine', 'color_darkTurquoise', 'color_darkBlue'];
  }
  return oppositeColorNames;
}

List<double> stepSort(RGBColor rgb, { int step = 1 }) {
  List<double> val = rgb.getValues();
  double threshold = 0.085;
  bool isGray = ((val[0] - val[1]).abs() < threshold && (val[0] - val[2]).abs() < threshold && (val[1] - val[2]).abs() < threshold);
  double lum = 0.241 * val[0] + 0.691 * val[1] + 0.068 * val[2];
  List<double> hsvVal = RGBtoHSV(rgb).getValues();
  double h2 = (hsvVal[0] * step).roundToDouble();
  double v2 = (hsvVal[2] * step).roundToDouble();
  double lum2 = (lum * step).roundToDouble();
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - step
  if(isGray) {
    return [1, step - v2, step - lum2, h2];
  }
  return [0, h2, lum2, v2];
}

List<double> colorWheelSort(RGBColor rgb, { int step = 1 }) {
  List<double> sort = stepSort(rgb, step: step);
  Map<String, RGBColor> colorWheel = createColorWheel();
  double minDist = 1000;
  int minIndex = 0;
  LabColor color0 = RGBtoLab(rgb);
  List<String> keys = colorWheel.keys.toList();
  for(int i = 0; i < keys.length; i++) {
    String color = keys[i];
    LabColor color1 = RGBtoLab(colorWheel[color]);
    double dist = deltaECie2000(color0, color1);
    if(dist < minDist) {
      minDist = dist;
      minIndex = i;
    }
  }
  //colorName: 0 - colorWheel.length
  //h: 0 - step
  //v2: 0 - step
  //lum2: 0 - step
  if(sort[0] == 1) {
    return [minIndex.toDouble(), sort[1], sort[2], sort[3]];
  }
  double h = sort[1];
  if(h < step / 2) {
    h = step - h;
  }
  return [minIndex.toDouble(), h, sort[2], sort[3]];
}

List<double> colorSort(RGBColor rgb) {
  List<double> val = rgb.getValues();
  LabColor color0 = RGBtoLab(rgb);
  double threshold = 0.085;
  bool isGray = ((val[0] - val[1]).abs() < threshold && (val[0] - val[2]).abs() < threshold && (val[1] - val[2]).abs() < threshold);
  //isGray: 0 - 1
  //diff: 0 - 100
  if(isGray) {
    LabColor color1 = RGBtoLab(RGBColor(0, 0, 0));
    return [0, deltaECie2000(color0, color1)];
  }
  LabColor color1 = RGBtoLab(RGBColor(1, 0, 0));
  return [1, deltaECie2000(color0, color1)];
}

List<double> distanceSort(RGBColor rgb, RGBColor org) {
  //diff: 0 - 100
  return [deltaECie2000(RGBtoLab(rgb), RGBtoLab(org))];
}

List<double> finishSort(Swatch swatch, { int step = 1, String firstFinish = '' }) {
  List<double> sort = stepSort(swatch.color, step: step);
  double finish = 10;
  switch(swatch.finish.toLowerCase()) {
    case 'finish_matte':
      finish = 1;
      break;
    case 'finish_satin':
      finish = 2;
      break;
    case 'finish_shimmer':
      finish = 3;
      break;
    case 'finish_metallic':
      finish = 4;
      break;
    case 'finish_glitter':
      finish = 5;
      break;
    default:
      finish = 10;
      break;
  }
  if(swatch.finish.toLowerCase() == firstFinish) {
    finish = 0;
  }
  //finish: 0 - 10
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - step
  return [finish, sort[0], sort[1], sort[2], sort[3]];
}

double round(double val) {
  //rounds to certain step
  return ((val * 2).round().toDouble() / 2);
}

List<double> lightestSort(Swatch swatch, { int step = 1 }) {
  List<double> sort = darkestSort(swatch, step: step);
  //v: 0 - 1
  //s: 0 - step
  //h2: 0 - step
  //lum2: 0 - step
  return [step - sort[0], step - sort[1], sort[2], sort[2]];
}

List<double> darkestSort(Swatch swatch, { int step = 1 }) {
  List<double> sort = stepSort(swatch.color, step: step);
  List<double> hsvVal = RGBtoHSV(swatch.color).getValues();
  double v = ((hsvVal[2] * 2).round().toDouble() / 2) * step;
  double s = hsvVal[1] * step;
  if(v > step / 2) {
    s = step - s;
  }
  //v: 0 - step
  //s: 0 - step
  //h2: 0 - step
  //lum2: 0 - step
  if(sort[0] == 1) {
    return [v, s, sort[2], sort[3]];
  }
  return [v, s, sort[1], sort[2]];
}

List<double> paletteSort(Swatch swatch, List<Swatch> swatches, { int step = 1 }) {
  List<double> sort = stepSort(swatch.color, step: step);
  List<String> palettes = [];
  for(int i = 0; i < swatches.length; i++) {
    if(!palettes.contains(swatches[i].palette)) {
      palettes.add(swatches[i].palette);
    }
  }
  //palette: 0 - (palettes.length - 1)
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - (360 * step)
  return [palettes.indexOf(swatch.palette).toDouble(), sort[0], sort[1], sort[2], sort[3]];
}

List<double> brandSort(Swatch swatch, List<Swatch> swatches, { int step = 1 }) {
  List<double> sort = stepSort(swatch.color, step: step);
  List<String> brands = [];
  for(int i = 0; i < swatches.length; i++) {
    if(!brands.contains(swatches[i].brand)) {
      brands.add(swatches[i].brand);
    }
  }
  //palette: 0 - (palettes.length - 1)
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - (360 * step)
  return [brands.indexOf(swatch.brand).toDouble(), sort[0], sort[1], sort[2], sort[3]];
}

List<double> highestRatedSort(Swatch swatch, { int step = 1}) {
  List<double> sort = stepSort(swatch.color, step: step);
  double rating = 10.0 - swatch.rating;
  //rating: 1 - 10
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - (360 * step)
  return [rating, sort[0], sort[1], sort[2], sort[3]];
}

List<double> lowestRatedSort(Swatch swatch, { int step = 1}) {
  List<double> sort = stepSort(swatch.color, step: step);
  double rating = swatch.rating.toDouble();
  //rating: 1 - 10
  //isGray: 0 - 1
  //h2: 0 - step
  //v2: 0 - step
  //lum2: 0 - (360 * step)
  return [rating, sort[0], sort[1], sort[2], sort[3]];
}