import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:mywallet/widget/theme.dart';

class Utils {

  static String truncateIfAddress(String input, {int? leadingDigits, int? trailingDigits}){
    var regex = RegExp('^(0x[a-zA-Z0-9]{${trailingDigits ?? 6}})[a-zA-Z0-9]+([a-zA-Z0-9]{${trailingDigits ?? 6}})\$');
    var matches = regex.allMatches(input);
    if (matches.isEmpty) {
      return input;
    }
    return "${matches.first.group(1)}...${matches.first.group(2)}";
  }

  static String truncate(String input, {int? leadingDigits, int? trailingDigits}){
    var regex = RegExp('^((?:0x)?.{${leadingDigits ?? 6}}).+(.{${trailingDigits ?? 6}})\$');
    var matches = regex.allMatches(input);
    if (matches.isEmpty) {
      return input;
    }
    String result = "${matches.first.group(1)}...${matches.first.group(2)}";
    result = utf8.decode(result.codeUnits, allowMalformed: true);
    result = result.replaceAll('\uFFFD', "");
    return result;
  }

  static void copyText(String text, {String? message}) {
    Clipboard.setData(ClipboardData(text: text));
    BotToast.showText(
      text: message ?? "Copied to clipboard!",
      textStyle: TextStyle(fontFamily: AppThemes.fonts.gilroyBold, color: Colors.black),
      contentColor: Get.theme.colorScheme.primary,
      align: Alignment.topCenter,
    );
  }

  static toast(String txt){
    BotToast.showText(
      text:  txt ,
      textStyle: TextStyle(fontFamily: AppThemes.fonts.gilroyBold, color: Colors.black),
      contentColor: Get.theme.colorScheme.error,
      align: Alignment.topCenter,
    );
  }
}