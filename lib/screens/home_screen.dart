import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_project/models/football_match.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    // Analytics User ID
    FirebaseAnalytics.instance.setUserId(
      id: FirebaseAuth.instance.currentUser?.uid,
    );

    // Crashlytics Log
    FirebaseCrashlytics.instance.log('Opened Home Screen');

    // Analytics Event
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'HomeScreen',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _onTapLogoutButton,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('football')
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            FirebaseCrashlytics.instance.recordError(
              snapshot.error,
              null,
            );

            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          List<FootballMatch> footballMatchList = [];

          for (DocumentSnapshot doc in snapshot.data!.docs) {
            footballMatchList.add(
              FootballMatch.fromJson(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            );
          }

          return ListView.separated(
            itemCount: footballMatchList.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final FootballMatch match =
              footballMatchList[index];

              return Dismissible(
                key: Key(match.id),
                onDismissed: (_) {
                  _onDismissed(match.id);
                },
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor: match.isRunning
                        ? Colors.green
                        : Colors.grey,
                  ),
                  title: Text(
                    '${match.team1Name} vs ${match.team2Name}',
                  ),
                  subtitle: Text(
                    'Winner Team: ${match.winnerTeam}',
                  ),
                  trailing: Text(
                    '${match.team1Score}-${match.team2Score}',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _onTapAddNewMatch,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onTapLogoutButton() {
    FirebaseCrashlytics.instance.log(
      'Logout button pressed',
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'logout_pressed',
    );

    FirebaseAuth.instance.signOut();
  }

  void _onTapAddNewMatch() {
    FirebaseAnalytics.instance.logEvent(
      name: 'add_match_pressed',
    );

    FirebaseCrashlytics.instance.log(
      'Adding new football match',
    );

    FootballMatch footballMatch = FootballMatch(
      id: 'portvsmor',
      team1Name: 'Brazil',
      team2Name: 'Morocco',
      team1Score: 1,
      team2Score: 1,
      winnerTeam: 'Brazil',
      isRunning: true,
    );

    FirebaseFirestore.instance
        .collection('football')
        .doc(footballMatch.id)
        .set(footballMatch.toJson());
  }

  void _onDismissed(String docId) {
    FirebaseAnalytics.instance.logEvent(
      name: 'match_deleted',
      parameters: {
        'match_id': docId,
      },
    );

    FirebaseCrashlytics.instance.log(
      'Deleted match: $docId',
    );

    FirebaseFirestore.instance
        .collection('football')
        .doc(docId)
        .delete();
  }
}