import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rajunews/models/category_model.dart';
import 'package:rajunews/models/slider_model.dart';
import 'package:rajunews/service/data.dart';
import 'package:rajunews/service/slider.data.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel> categories = [];
  List<sliderModel>sliders=[];

  @override
  void initState() {
    categories = getCategories();
    sliders= getSliders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.all(8.0), child: Text("shiva")),
            Text(
              "news",
              style: TextStyle(color: Colors.pinkAccent, height: 43),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10),
              height: 70,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryTitle(
                    image: categories[index].image,
                    categoryName: categories[index].categoryName,
                  );
                },
              ),
            ),
            CarouselSlider.builder(itemCount: sliders.length, itemBuilder:(context, index,) , options: options)
          ],
        ),
      ),
    );
  }
  Widget builderImage(String image, int index, String name)=>Container(
    child:  Image.asset(image, fit: BoxFit.cover,width: MediaQuery.of(context).size.width),
  );
}



class CategoryTitle extends StatelessWidget {
  final image, categoryName;

  CategoryTitle({this.categoryName, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.asset(
              image,
              width: 120,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: 120,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.black38,
            ),

            child: Center(
              child: Text(
                categoryName,
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

