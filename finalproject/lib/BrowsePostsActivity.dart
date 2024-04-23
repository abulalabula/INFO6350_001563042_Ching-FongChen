import 'package:flutter/material.dart';
import 'NewPostActivity.dart';
import 'database_helper.dart';
import 'PostDetailActivity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BrowsePostsActivity extends StatefulWidget {
  const BrowsePostsActivity({Key? key}) : super(key: key);

  @override
  _BrowsePostsActivityState createState() => _BrowsePostsActivityState();
}

class _BrowsePostsActivityState extends State<BrowsePostsActivity> {
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final data = await DatabaseHelper.instance.fetchPosts();
    setState(() {
      _posts = data;
    });
  }

  void _navigateToNewPost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewPostActivity()),
    ).then((_) => _loadPosts());
  }

void _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    if (result == true && mounted) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacementNamed('/signin');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Logout failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Browse current items', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _confirmLogout,
            tooltip: 'Logout',
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu), // The menu icon
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 80, // height of drawer, align with appbar for UI consistency 
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0), 
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.post_add),
              title: Text('New Post'),
              onTap: _navigateToNewPost,
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return ListTile(
            title: Text(post['title']),
            subtitle: Text(post['description']),
            trailing: Text('\$${post['price']}'),
            onTap: () async {
              // Fetching post by id to pass data in SQLite
              try {
                Map<String, dynamic> detailedPost =
                    await DatabaseHelper.instance.fetchPostById(post['id']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailActivity(
                        post: detailedPost,
                        imagePaths: detailedPost['image'].split(';')),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewPost,
        child: Icon(Icons.add),
        tooltip: 'Add New Post',
      ),
    );
  }
}
