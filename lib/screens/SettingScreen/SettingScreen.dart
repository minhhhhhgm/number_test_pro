import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/setting_bloc.dart';
import 'bloc/setting_event.dart';
import 'bloc/setting_state.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingBloc()..add(LoadSetting()),
      child: BlocBuilder<SettingBloc, SettingState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Cài đặt'),
              backgroundColor: Colors.deepPurple,
            ),
            body: ListView(
              padding: EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: Text('Âm thanh'),
                  value: state.sound,
                  onChanged: (_) => context.read<SettingBloc>().add(ToggleSound()),
                ),
                SwitchListTile(
                  title: Text('Hiệu ứng'),
                  value: state.effect,
                  onChanged: (_) => context.read<SettingBloc>().add(ToggleEffect()),
                ),
                SwitchListTile(
                  title: Text('Rung'),
                  value: state.vibration,
                  onChanged: (_) => context.read<SettingBloc>().add(ToggleVibration()),
                ),
                ListTile(
                  title: Text('Độ khó'),
                  trailing: DropdownButton<Difficulty>(
                    value: state.difficulty,
                    items: Difficulty.values.map((d) => DropdownMenuItem(
                      value: d,
                      child: Text(d.toString().split('.').last.toUpperCase()),
                    )).toList(),
                    onChanged: (d) {
                      if (d != null) context.read<SettingBloc>().add(ChangeDifficulty(d));
                    },
                  ),
                ),
                ListTile(
                  title: Text('Giao diện'),
                  trailing: DropdownButton<AppTheme>(
                    value: state.theme,
                    items: AppTheme.values.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t == AppTheme.light ? 'Sáng' : 'Tối'),
                    )).toList(),
                    onChanged: (t) {
                      if (t != null) context.read<SettingBloc>().add(ChangeTheme(t));
                    },
                  ),
                ),
                ListTile(
                  title: Text('Tên người chơi'),
                  subtitle: Text(state.userName.isNotEmpty ? state.userName : 'Chưa đặt tên'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      String? newName = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          String temp = state.userName;
                          return AlertDialog(
                            title: Text('Đổi tên'),
                            content: TextField(
                              autofocus: true,
                              decoration: InputDecoration(hintText: 'Nhập tên mới'),
                              onChanged: (v) => temp = v,
                            ),
                            actions: [
                              TextButton(
                                child: Text('Hủy'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: Text('Lưu'),
                                onPressed: () => Navigator.pop(context, temp),
                              ),
                            ],
                          );
                        },
                      );
                      if (newName != null && newName.trim().isNotEmpty) {
                        context.read<SettingBloc>().add(ChangeUserName(newName.trim()));
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Reset dữ liệu'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    context.read<SettingBloc>().add(ResetData());
                  },
                ),
                SizedBox(height: 32),
                Center(child: Text('Phiên bản: 1.0.0', style: TextStyle(color: Colors.grey))),
              ],
            ),
          );
        },
      ),
    );
  }
} 