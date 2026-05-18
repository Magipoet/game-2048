import 'package:flutter/material.dart';

import '../models/cell_type.dart';

class GameColors {
  static const Color backgroundColor = Color(0xFFFAF8EF);
  static const Color boardBackground = Color(0xFFBBADA0);
  static const Color emptyTile = Color(0xFFCDC1B4);
  static const Color scoreBackground = Color(0xFFBBADA0);
  static const Color buttonBackground = Color(0xFF8F7A66);
  static const Color textColor = Color(0xFF776E65);
  static const Color scoreTextColor = Color(0xFFFFFFFF);
  static const Color buttonTextColor = Color(0xFFFFFFFF);

  static const Color woodBlockColor = Color(0xFF8B4513);
  static const Color woodBlockTextColor = Color(0xFFFFFFFF);
  static const Color iceBlockColor = Color(0xFF87CEEB);
  static const Color iceBlockTextColor = Color(0xFF2F4F4F);

  static Color getTileColor(int value, {CellType? cellType}) {
    if (cellType == CellType.woodBlock) {
      return woodBlockColor;
    }
    if (cellType == CellType.iceBlock) {
      return iceBlockColor;
    }
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        return const Color(0xFF3C3A32);
    }
  }

  static Color getTileTextColor(int value, {CellType? cellType}) {
    if (cellType == CellType.woodBlock) {
      return woodBlockTextColor;
    }
    if (cellType == CellType.iceBlock) {
      return iceBlockTextColor;
    }
    return value <= 4 ? const Color(0xFF776E65) : const Color(0xFFF9F6F2);
  }

  static double getTileFontSize(int value, {CellType? cellType}) {
    if (cellType == CellType.woodBlock || cellType == CellType.iceBlock) {
      return 14;
    }
    if (value < 100) {
      return 32;
    } else if (value < 1000) {
      return 28;
    } else {
      return 24;
    }
  }
}
