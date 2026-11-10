import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'meal_api.g.dart';

@RestApi(baseUrl: 'https://www.themealdb.com/api/json/v1/1')
abstract class MealApi {
  factory MealApi(Dio dio, {String baseUrl}) = _MealApi;

  factory MealApi.create() => MealApi(
    Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    ),
  );

  @GET('/search.php')
  Future<dynamic> searchMeals(@Query('s') String query);
}
