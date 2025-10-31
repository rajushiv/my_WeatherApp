import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_tile.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();


  void _setupScroll(NewsProvider provider) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        provider.fetchNext();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // provider fetch in didChangeDependencies to ensure context available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<NewsProvider>(context, listen: false);
    if (provider.articles.isEmpty && !provider.isLoading) provider.fetchNext();
    _setupScroll(provider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter News'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => Provider.of<NewsProvider>(context, listen: false).refresh(),
          )
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.articles.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          if (provider.hasError && provider.articles.isEmpty) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }
          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: provider.articles.length + (provider.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => Divider(height: 0.5),
              itemBuilder: (context, index) {
                if (index >= provider.articles.length) {
                  // loading indicator at bottom
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final article = provider.articles[index];
                return ArticleTile(
                  article: article,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
