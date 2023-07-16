
import 'package:dio/dio.dart';

class RecentActivity{

  // 直接调用api  简单粗暴 
  static Future<String> fetch() async{
    String url = "https://api.etherscan.io/api?module=account&action=txlist&address=0x009D86FEBE28E48f1aa58B11602c01EEDdB9A28C&startblock=0&endblock=99999999&page=1&offset=10&sort=asc&apikey=AX5NHJ2AMZGUWMM5AXQK43V318QW4YVFP9";
    var response;
    await Dio().get(url).then((value) =>
      response = value
    );
    print('response is : $response');
    return "";
  }
}