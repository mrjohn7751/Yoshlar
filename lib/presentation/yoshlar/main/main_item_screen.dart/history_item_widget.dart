import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/model/activity.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final String? youthName;

  const ActivityCard({super.key, required this.activity, this.youthName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (activity.id != null) {
          final authState = context.read<AuthCubit>().state;
          final routeName =
              (authState is AuthAuthenticated && authState.user.isMasul)
              ? 'masul_history_into_page'
              : 'history_into_page';
          context.pushNamed(
            routeName,
            extra: {'activityId': activity.id, 'youthName': youthName},
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (activity.result.isNotEmpty)
                Text(
                  "Натижа: ${activity.result}",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                activity.dateWithTime,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
