import 'dart:math';
import 'dart:ui';
import '../Widgets/Swatch.dart';
import 'ColorObjects.dart';
import 'ColorDifferences.dart';
import 'ColorConversions.dart';
import 'ColorSorting.dart';

List<Swatch> getRandomLook(List<Swatch> swatches, int numSwatches, int type, int subtype, List<String> possibleColorCategories, List<String> possibleFinishes) {
  //should swatches already be filtered? probably no
  //numSwatches should be 2-7 or 2-8?
  //type is either 1=monochromatic, 2=duochromatic, 3=trichromatic, or random
  //subtype is 1=analogous or 2=complementary or random if duochromatic, 1=analogous or 2=split complementary or 3=triad or random if trichromatic, and does not apply for monochromatic
  //possibleColorCategories is either neutral, red, orange, yellow, green, blue, purple, or pink
  //possibleFinishes is matte, satin, shimmer, metallic, or glitter
  //order of return list is important

  //nothing to work with in some aspect so just give empty list as optimization
  if(swatches.length == 0 || numSwatches == 0 || possibleColorCategories.length == 0 || possibleFinishes.length == 0) {
    return [];
  }
  //not enough swatches, so just return all of them
  if(swatches.length <= numSwatches) {
    return swatches.toList();
  }

  Random random = Random();
  List<Swatch> ret = [];
  List<Swatch> possibleSwatches = swatches.toList();

  //step 1: if type == random, choose either monochromatic, duochromatic, or trichromatic
  if(type < 1) {
    type = random.nextInt(3) + 1;
  }

  //step 2: make sure all values work, type needs to be less than possible color categories and numSwatches
  if(type > numSwatches) {
    type = numSwatches;
  }
  if(type > possibleColorCategories.length) {
    type = possibleColorCategories.length;
  }

  //step 3: choose subtype
  //ignore if monochromatic
  switch(type) {
    case 2: {
      if(subtype < 1) {
        subtype = random.nextInt(2) + 1;
      }
      //might happen if was selected to be trichromatic but was invalid and became duochromatic, therefore go to closest mode
      if(subtype > 2) {
        subtype = 2;
      }
      break;
    }
    case 3: {
      if(subtype < 1) {
        subtype = random.nextInt(3) + 1;
      }
      break;
    }
  }

  //step 4: choose color categories
  List<HSVColor> colorCategories = [];
  List<double> startColorDist = [];
  List<double> endColorDist = [];
  Map<String, HSVColor> colorWheel = createColorWheel();
  List<String> colorNames = colorWheel.keys.toList();
  List<int> indexes = getColorIndexes(possibleColorCategories, colorNames);
  switch(type) {
    //type = monochromatic
    case 1: {
      colorCategories = getMonochromaticColors(colorWheel, indexes, colorNames, random);
      break;
    }
    //type = duochromatic
    case 2: {
      colorCategories = getDuochromaticColors(colorWheel, indexes, colorNames, subtype, random);
      break;
    }
    //type = trichromatic
    case 3: {
      colorCategories = getTrichromaticColors(colorWheel, indexes, colorNames, subtype, random);
      break;
    }
  }
  for(int i = 0; i < type; i++) {
    List<double> dist = getHueDist(colorWheel, colorCategories[i], colorNames);
    startColorDist.add(dist[0]);
    endColorDist.add(dist[1]);
  }

  //step 5: decide on finishes for each color
  List<List<String>> finishes = getFinishes(possibleFinishes, random);
  String blendFinish = finishes[0][0];
  String lidFinish = finishes[1][0];
  List<String> possibleBlendFinishes = finishes[2];
  List<String> possibleLidFinishes = finishes[3];

  //step 6: decide on number of shades for blend and lid
  int numBlend = (numSwatches / 3 * 2).round();
  int numLid = (numSwatches / 3).round();
  //chance to have more blend than lid shades
  if(numSwatches > 3) {
    int chance = random.nextInt(3);
    if(chance == 0) {
      numBlend++;
      numLid--;
    }
  }

  //step 7: decide on number of shades for each color
  List<List<int>> numEachColor = getNumEachColor(type, numBlend, numLid);
  List<int> numBlendEachColor = numEachColor[0];
  List<int> numLidEachColor = numEachColor[1];

  //step 8: if less than 3 per color per finish, generate base color and maybe random lighter or darker; otherwise, generate light and dark color and colors in between
  for(int i = 0; i < type; i++) {
    List<double> colorValues = colorCategories[i].getValues();
    List<List<Swatch>> range = generateRange(possibleSwatches, colorValues, startColorDist[i], endColorDist[i], numBlendEachColor[i], blendFinish, possibleBlendFinishes, 13, random);
    ret.addAll(range[0]);
    //swatches is adjusted to avoid reuse
    possibleSwatches = range[1];

    range = generateRange(possibleSwatches, colorValues, startColorDist[i], endColorDist[i], numLidEachColor[i], lidFinish, possibleLidFinishes, 13, random);
    ret.addAll(range[0]);
    //swatches is adjusted to avoid reuse
    possibleSwatches = range[1];
  }

  return ret;
}

List<int> getColorIndexes(List<String> possibleColorCategories, List<String> colorNames) {
  List<int> indexes = [];
  for(int i = 0; i < possibleColorCategories.length; i++) {
    String color = possibleColorCategories[i].toLowerCase();
    if(color == 'neutral') {
      color = 'orange';
    }
    if(!indexes.contains(color)) {
      int index = colorNames.indexOf(color);
      if(index != -1) {
        indexes.add(index);
      }
    }
  }
  return indexes;
}

List<HSVColor> getMonochromaticColors(Map<String, HSVColor> colorWheel, List<int> indexes, List<String> colorNames, Random random) {
  int i = indexes[random.nextInt(indexes.length)];
  return [colorWheel[colorNames[i]]!];
}

List<HSVColor> getDuochromaticColors(Map<String, HSVColor> colorWheel, List<int> indexes, List<String> colorNames, int subtype, Random random) {
  List<HSVColor> ret = [];

  if(subtype == 1) {

    //subtype = analogous
    List<int> analogous = getAnalogousIndexes(indexes, colorNames.length, 2);

    if(analogous.length == 0) {
      //no analogous colors, so just choose random colors
      int i = random.nextInt(indexes.length);
      String color = colorNames[indexes[i]];
      ret.add(colorWheel[color]!);
      color = colorNames[indexes[(i + 1) % indexes.length]];
      ret.add(colorWheel[color]!);
    } else {
      int i = analogous[random.nextInt(analogous.length)];
      ret.add(colorWheel[colorNames[i]]!);
      ret.add(colorWheel[colorNames[(i + 1) % colorNames.length]]!);
    }

  } else {

    //subtype = complementary
    List<int> complementary = getComplementaryIndexes(indexes, colorNames.length);

    if(complementary.length == 0) {
      //no complementary colors, so just choose random colors
      int i = random.nextInt(indexes.length);
      String color = colorNames[indexes[i]].toLowerCase();
      ret.add(colorWheel[color]!);

      color = colorNames[indexes[(i + (indexes.length / 2).round()) % indexes.length]].toLowerCase();
      ret.add(colorWheel[color]!);
    } else {
      int i = complementary[random.nextInt(complementary.length)];
      ret.add(colorWheel[colorNames[i]]!);
      ret.add(colorWheel[colorNames[(i + (colorNames.length / 2).round()) % colorNames.length]]!);
    }

  }

  return shuffleColors(ret, random);
}

List<HSVColor> getTrichromaticColors(Map<String, HSVColor> colorWheel, List<int> indexes, List<String> colorNames, int subtype, Random random) {
  List<HSVColor> ret = [];

  if(subtype == 1) {

    //subtype = analogous
    List<int> analogous = getAnalogousIndexes(indexes, colorNames.length, 3);

    if(analogous.length == 0) {
      //no analogous colors, so just choose random colors
      int i = random.nextInt(indexes.length);
      String color = colorNames[indexes[i]];
      ret.add(colorWheel[color]!);

      color = colorNames[indexes[(i + 1) % indexes.length]];
      ret.add(colorWheel[color]!);

      color = colorNames[indexes[(i + 2) % indexes.length]];
      ret.add(colorWheel[color]!);
    } else {
      int i = analogous[random.nextInt(analogous.length)];
      ret.add(colorWheel[colorNames[i]]!);
      ret.add(colorWheel[colorNames[(i + 1) % colorNames.length]]!);
      ret.add(colorWheel[colorNames[(i + 2) % colorNames.length]]!);
    }

    ret = shuffleColors(ret, random);

  } else if(subtype == 2) {

    //subtype = split complementary
    List<int> splitComplementary = getSplitComplementaryIndexes(indexes, colorNames.length);

    if(splitComplementary.length == 0) {
      //no split complementary colors, so just choose random colors
      int i = random.nextInt(indexes.length);
      int complementary = i + (indexes.length / 2).round();
      String color = colorNames[indexes[i]];
      ret.add(colorWheel[color]!);

      color = colorNames[indexes[(complementary) % indexes.length]];
      ret.add(colorWheel[color]!);

      color = colorNames[indexes[(complementary + 1) % indexes.length]];
      ret.add(colorWheel[color]!);
    } else {
      int i = splitComplementary[random.nextInt(splitComplementary.length)];
      int complementary = i + (colorNames.length / 2).round();
      ret.add(colorWheel[colorNames[i]]!);
      ret.add(colorWheel[colorNames[(complementary) % colorNames.length]]!);
      ret.add(colorWheel[colorNames[(complementary + 1) % colorNames.length]]!);
    }

    ret = shuffleColors(ret, random);

  } else {

    //subtype = triad
    List<int> triad = getTriadIndexes(indexes, colorNames.length);

    if(triad.length == 0) {
      //no triad colors, so just choose random colors
      int i = random.nextInt(indexes.length);
      int third = (indexes.length / 3).round();
      String color = colorNames[indexes[i]];
      ret.add(colorWheel[color]!);

      color = colorNames[indexes[(i - third) % indexes.length]];
      ret.add(colorWheel[color]!);

      color = colorNames[indexes[(i + third) % indexes.length]];
      ret.add(colorWheel[color]!);
    } else {
      int i = triad[random.nextInt(triad.length)];
      int third = (colorNames.length / 3).ceil();
      ret.add(colorWheel[colorNames[i]]!);
      ret.add(colorWheel[colorNames[(i - third) % colorNames.length]]!);
      ret.add(colorWheel[colorNames[(i + third) % colorNames.length]]!);
    }

    for(int i = 0; i < 3 ; i++) {
      //shuffle
      HSVColor index = ret[i];
      ret.remove(index);
      ret.insert(random.nextInt(3), index);
    }

  }

  return ret;
}

List<double> getHueDist(Map<String, HSVColor> colorWheel, HSVColor color, List<String> colorNames) {
  int i = colorWheel.values.toList().indexOf(color);
  double hue = color.getValues()[0];
  double startDist = (colorWheel[colorNames[(i - 1) % colorNames.length]]!.getValues()[0] - hue).abs();
  if(startDist > 120) {
    //distance is too great, most likely looped over
    startDist = ((360 - colorWheel[colorNames[(i - 1) % colorNames.length]]!.getValues()[0]) - hue).abs();
  }
  double endDist = (colorWheel[colorNames[(i + 1) % colorNames.length]]!.getValues()[0] - hue).abs();
  if(endDist > 120) {
    //distance is too great, most likely looped over
    endDist = ((360 + colorWheel[colorNames[(i + 1) % colorNames.length]]!.getValues()[0]) - hue).abs();
  }
  return [startDist, endDist];
}

List<int> getAnalogousIndexes(List<int> indexes, int total, int num) {
  List<int> ret = [];
  int currNum = 0;
  for(int i = 0; i < total + (num - 1); i++) {
    if(!indexes.contains(i % total)) {
      currNum = 0;
      continue;
    }
    currNum++;
    if(currNum == num) {
      currNum--;
      ret.add(i - currNum);
    }
  }
  return ret;
}

List<int> getComplementaryIndexes(List<int> indexes, int total) {
  List<int> ret = [];
  for(int i = 0; i < indexes.length; i++) {
    if(indexes.contains((indexes[i] + (total / 2).round()) % total)) {
      ret.add(indexes[i]);
    }
  }
  return ret;
}

List<int> getSplitComplementaryIndexes(List<int> indexes, int total) {
  List<int> ret = [];
  for(int i = 0; i < indexes.length; i++) {
    int complementary = indexes[i] + (total / 2).round();
    if(indexes.contains((complementary).round() % total) && indexes.contains((complementary + 1).round() % total)) {
      ret.add(indexes[i]);
    }
  }
  return ret;
}

List<int> getTriadIndexes(List<int> indexes, int total) {
  List<int> ret = [];
  for(int i = 0; i < indexes.length; i++) {
    int third = (total / 3).ceil();
    if(indexes.contains((indexes[i] - third) % total) && indexes.contains((indexes[i] + third) % total)) {
      ret.add(indexes[i]);
    }
  }
  return ret;
}


List<HSVColor> shuffleColors(List<HSVColor> colors, Random random) {
  List<HSVColor> ret = colors.toList();
  if(random.nextBool()) {
      //shuffle
      HSVColor first = ret[0];
      ret.remove(first);
      ret.add(first);
  }
  return ret;
}

List<List<String>> getFinishes(List<String> possibleFinishes, Random random) {
  //TODO: weight against glitter?
  String blendFinish = possibleFinishes[0];
  List<String> possibleBlendFinishes = [];
  String lidFinish = possibleFinishes[0];
  List<String> possibleLidFinishes = [];
  if(possibleFinishes.length != 1) {
    bool hasMatte = possibleFinishes.contains('finish_matte');
    if(hasMatte) {
      possibleBlendFinishes.add('finish_matte');
    }

    bool hasSatin = possibleFinishes.contains('finish_satin');
    if(hasSatin) {
      possibleBlendFinishes.add('finish_satin');
    }

    bool hasShimmer = possibleFinishes.contains('finish_shimmer');
    if(hasShimmer) {
      possibleLidFinishes.add('finish_shimmer');
    }

    bool hasMetallic = possibleFinishes.contains('finish_metallic');
    if(hasMetallic) {
      possibleLidFinishes.add('finish_metallic');
    }

    bool hasGlitter = possibleFinishes.contains('finish_glitter');
    if(hasGlitter) {
      possibleLidFinishes.add('finish_glitter');
    }

    if(hasShimmer || hasMetallic || hasGlitter) {
      if(hasMatte || hasSatin) {
        int possibleLidFinishes = (hasShimmer ? 1 : 0);
        possibleLidFinishes += (hasMetallic ? 1 : 0);
        possibleLidFinishes += (hasGlitter ? 1 : 0);
        int choice = random.nextInt(possibleLidFinishes);
        switch(choice) {
          case 2: {
            lidFinish = 'finish_glitter';
            break;
          }
          case 1: {
            lidFinish = (hasShimmer && hasMetallic ? 'finish_metallic' : 'finish_glitter');
            break;
          }
          case 0: {
            lidFinish = (hasShimmer ? 'finish_shimmer' : (hasMetallic ? 'finish_metallic' : 'finish_glitter'));
            break;
          }
        }
        if(hasMatte && hasSatin) {
          int choice = random.nextInt(6);
          if(choice < 5) {
            blendFinish = 'finish_matte';
          } else {
            blendFinish = 'finish_satin';
          }
        } else {
          if(hasMatte) {
            blendFinish = 'finish_matte';
          } else {
            blendFinish = 'finish_satin';
          }
        }
      } else {
        if(hasShimmer) {
          blendFinish = 'finish_shimmer';
          if(hasMetallic && hasGlitter) {
            int choice = random.nextInt(2);
            if(choice == 0) {
              lidFinish = 'finish_metallic';
            } else {
              lidFinish = 'finish_glitter';
            }
          } else if(hasMetallic) {
            lidFinish = 'finish_metallic';
          } else {
            lidFinish = 'finish_glitter';
          }
        } else {
          blendFinish = 'finish_metallic';
          lidFinish = 'finish_glitter';
        }
      }
    } else {
      //finishes must be finish_matte and finish_satin
      blendFinish = 'finish_matte';
      lidFinish = 'finish_satin';
    }
  }
  return [[blendFinish], [lidFinish], possibleBlendFinishes, possibleLidFinishes];
}

List<List<int>> getNumEachColor(int type, int numBlend, int numLid) {
  List<int> numBlendEachColor = [];
  List<int> numLidEachColor = [];
  switch(type) {
    case 1: {
      numBlendEachColor = [numBlend];
      numLidEachColor = [numLid];
      break;
    }
    case 2: {
      numBlendEachColor = [
        (numBlend / 2).ceil(),
        (numBlend / 2).floor(),
      ];
      numLidEachColor = [
        (numLid / 2).floor(),
        (numLid / 2).ceil(),
      ];
      break;
    }
    case 3: {
      if(numBlend % 3 == 1) {
        numBlendEachColor = [
          (numBlend / 3).floor(),
          (numBlend / 3).ceil(),
          (numBlend / 3).floor(),
        ];
      } else if(numBlend % 3 == 2) {
        numBlendEachColor = [
          (numBlend / 3).ceil(),
          (numBlend / 3).ceil(),
          (numBlend / 3).floor(),
        ];
      } else {
        numBlendEachColor = [
          (numBlend / 3).round(),
          (numBlend / 3).round(),
          (numBlend / 3).round(),
        ];
      }
      if(numLid % 3 == 1) {
        numLidEachColor = [
          (numLid / 3).floor(),
          (numLid / 3).floor(),
          (numLid / 3).ceil(),
        ];
      } else if(numLid % 3 == 2) {
        numLidEachColor = [
          (numLid / 3).ceil(),
          (numLid / 3).floor(),
          (numLid / 3).ceil(),
        ];
      } else {
        numLidEachColor = [
          (numLid / 3).round(),
          (numLid / 3).round(),
          (numLid / 3).round(),
        ];
      }
      break;
    }
  }
  return [numBlendEachColor, numLidEachColor];
}

List<List<Swatch>> generateRange(List<Swatch> swatches, List<double> orgColorValues, double startDist, double endDist, int numShades, String finish, List<String> possibleFinishes, double maxColorDistance, Random random) {
  //TODO: maybe ensure certain minimum distance between shades?
  List<Swatch> ret = [];
  List<double> startValues;
  List<double> endValues;

  double startPercent = startDist * 0.43;
  double endPercent = endDist * 0.43;
  double hueStart;
  double hueEnd;
  if(random.nextBool()) {
    hueStart = -random.nextDouble() * (startPercent / 2);
  } else {
    hueStart = random.nextDouble() * (endPercent / 2);
  }
  //make hue end less extreme to ensure that the hue stays within certain range
  if(random.nextBool()) {
    hueEnd = -random.nextDouble() * (startPercent / 3);
  } else {
    hueEnd = random.nextDouble() * (endPercent / 3);
  }

  if(numShades == 1) {
    startValues = [orgColorValues[0] + hueStart, (random.nextDouble() * 0.6) + 0.4, (random.nextDouble() * 0.6) + 0.4];
    endValues = startValues;
  } else if(numShades == 2) {
    startValues = [orgColorValues[0] + hueStart, (random.nextDouble() * 0.34) + 0.43, (random.nextDouble() * 0.24) + 0.48];
    if(random.nextBool()) {
      endValues = startValues.toList();
      startValues = [orgColorValues[0] + hueEnd, (random.nextDouble() * 0.25) + 0.15, (random.nextDouble() * 0.2) + 0.8];
    } else {
      endValues = [orgColorValues[0] + hueEnd, (random.nextDouble() * 0.35) + 0.65, (random.nextDouble() * 0.3) + 0.1];
    }
  } else {
    startValues = [orgColorValues[0] + hueStart, (random.nextDouble() * 0.25) + 0.15, (random.nextDouble() * 0.2) + 0.8];
    endValues = [orgColorValues[0] + hueEnd, (random.nextDouble() * 0.35) + 0.65, (random.nextDouble() * 0.3) + 0.1];
  }

  for(int i = 0; i < numShades; i++) {
    //avoid 0/0 error
    double percent = i / (numShades == 1 ? 1.0 : (numShades - 1.0));
    HSVColor color = HSVColor(lerpDouble(startValues[0], endValues[0], percent)! % 360, lerpDouble(startValues[1], endValues[1], percent)!, lerpDouble(startValues[2], endValues[2], percent)!);
    Swatch swatch = findClosestSwatch(HSVtoRGB(color), swatches, finish: finish, possibleFinishes: possibleFinishes, maxColorDistance: maxColorDistance);
    swatches.remove(swatch);
    ret.add(swatch);
  }

  return [ret, swatches];
}

Swatch findClosestSwatch(RGBColor rgb, List<Swatch> swatches, { String finish = '', List<String>? possibleFinishes, double maxColorDistance = -1 }) {
  LabColor color0 = RGBtoLab(rgb);
  double minDist = 1000;
  int minIndex = 0;
  //keep backup in case there's no close enough color and to avoid looping large list twice
  double possibleMinDist = 1000;
  int possibleMinIndex = 0;
  for(int i = 0; i < swatches.length; i++) {
    if(swatches[i].finish == finish) {
      LabColor color1 = RGBtoLab(swatches[i].color);
      double dist = deltaECie2000(color0, color1);
      if(dist < minDist) {
        minDist = dist;
        minIndex = i;
      }
      continue;
    } else if(maxColorDistance != -1 && possibleFinishes!.contains(swatches[i].finish)) {
      LabColor color1 = RGBtoLab(swatches[i].color);
      double dist = deltaECie2000(color0, color1);
      if(dist < possibleMinDist) {
        possibleMinDist = dist;
        possibleMinIndex = i;
      }
    }
  }
  if(maxColorDistance != -1 && minDist > maxColorDistance && possibleMinDist < minDist) {
    return swatches[possibleMinIndex];
  }
  return swatches[minIndex];
}