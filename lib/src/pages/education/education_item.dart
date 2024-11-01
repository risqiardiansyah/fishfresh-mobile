import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationItem extends StatelessWidget {
  final String title;
  final String image;
  final String link;
  final String date;
  final String author;

  const EducationItem({
    super.key,
    required this.title,
    required this.image,
    required this.date,
    required this.author,
    required this.link,
  });

  _launchURL() async {
    if (link.isNotEmpty) {
      final Uri url = Uri.parse(link);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(image);

    return InkWell(
      onTap: () {
        _launchURL();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                image,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print(error);
                  return Image.asset(
                    'assets/images/default.png',
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Row(
                              children: [
                                Text(
                                  author,
                                  style:
                                      const TextStyle(color: Color(0xffC1C1C1)),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.verified_outlined,
                                  color: Color(0xff08244d),
                                  size: 14.0,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '·',
                            style: TextStyle(color: Color(0xffC1C1C1)),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              date,
                              style: const TextStyle(color: Color(0xffC1C1C1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
