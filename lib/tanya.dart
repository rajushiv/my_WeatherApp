import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';

class ArticleTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  const ArticleTile({required this.article, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: article.urlToImage != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 90,
          height: 60,
          child: CachedNetworkImage(
            imageUrl: article.urlToImage!,
            fit: BoxFit.cover,
            placeholder: (c, s) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: (c, s, e) => Icon(Icons.broken_image),
          ),
        ),
      )
          : null,
      title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: article.description != null ? Text(article.description!, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}
