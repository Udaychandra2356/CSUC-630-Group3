import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:habitstacker/add_habit_flow.dart';
import 'profile_screen.dart';
import 'planner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _tabs = [
    DashboardScreen(),
    PlannerScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];
  void _onTapNav(int i) => setState(() => _selectedIndex = i);

  void _showCalendar() {
    final today = DateTime.now();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Calendar'),
        content: SizedBox(
          width: 320,
          height: 330,
          child: CalendarDatePicker(
            initialDate: today,
            firstDate: today.subtract(const Duration(days: 365)),
            lastDate: today.add(const Duration(days: 365)),
            onDateChanged: (_) {},
          ),
        ),
        actions:[TextButton(onPressed:()=>Navigator.pop(context), child:const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) => Scaffold(
    appBar: AppBar(
      title: const Text('Today'), centerTitle: true,
      leading: IconButton(icon:const Icon(Icons.settings), onPressed: ()=>_onTapNav(3)),
      actions:[IconButton(icon:const Icon(Icons.calendar_month), onPressed: _showCalendar)],
    ),
    body: _tabs[_selectedIndex],
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: ()=>Navigator.push(ctx,MaterialPageRoute(builder:(_) => const AddHabitsScreen())),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex:_selectedIndex,onTap:_onTapNav,type:BottomNavigationBarType.fixed,
      items:const[
        BottomNavigationBarItem(icon:Icon(Icons.home),label:'Dashboard'),
        BottomNavigationBarItem(icon:Icon(Icons.calendar_today),label:'Planner'),
        BottomNavigationBarItem(icon:Icon(Icons.bar_chart),label:'Analytics'),
        BottomNavigationBarItem(icon:Icon(Icons.person),label:'Profile'),
      ],
    ),
  );
}

/// ---------------- DASHBOARD TAB ----------------
class DashboardScreen extends StatefulWidget { const DashboardScreen({super.key}); @override State<DashboardScreen> createState()=>_DashboardScreenState();}
class _DashboardScreenState extends State<DashboardScreen>{
  final List<DateTime> _week=List.generate(7,(i){
    final now=DateTime.now();
    final monday=now.subtract(Duration(days: now.weekday-1));
    return monday.add(Duration(days:i));
  });
  int _dayIdx=DateTime.now().weekday-1;
  String _label(int i)=>['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i];

  @override
  Widget build(BuildContext ctx)=>Column(children:[
    Container(
      color:Colors.teal[100],padding:const EdgeInsets.symmetric(vertical:8),
      child:Row(
        mainAxisAlignment:MainAxisAlignment.spaceEvenly,
        children:List.generate(7,(i)=>GestureDetector(
          onTap:()=>setState(()=>_dayIdx=i),
          child:_DateColumn(dayLabel:_label(i),dayNumber:_week[i].day.toString(),isSelected:i==_dayIdx),
        )),
      ),
    ),
    Expanded(
      child:StreamBuilder<List<Habit>>(
        stream:HabitService().habitsForDay(_dayIdx),
        builder:(_,snap){
          if(snap.connectionState==ConnectionState.waiting){return const Center(child:CircularProgressIndicator());}
          final list=snap.data??[];
          final morning=list.where((h)=>h.targetTime.hour<12).toList();
          final noon   =list.where((h)=>h.targetTime.hour>=12 && h.targetTime.hour<17).toList();
          final eve    =list.where((h)=>h.targetTime.hour>=17).toList();
          return SingleChildScrollView(
            child:Column(children:[
              _TimeBlockCard(title:'Morning', habits:morning),
              _TimeBlockCard(title:'Noon',    habits:noon),
              _TimeBlockCard(title:'Evening', habits:eve),
            ]),
          );
        },
      ),
    ),
  ]);
}

/// --- small helper widgets ---
class _DateColumn extends StatelessWidget{
  final String dayLabel,dayNumber; final bool isSelected;
  const _DateColumn({required this.dayLabel,required this.dayNumber,this.isSelected=false});
  @override Widget build(BuildContext c)=>Container(
    padding:const EdgeInsets.symmetric(vertical:4,horizontal:10),
    decoration:isSelected?BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(4),border:Border.all(color:Colors.black26)):null,
    child:Column(children:[
      Text(dayLabel,style:const TextStyle(fontWeight:FontWeight.bold)),
      Text(dayNumber,style:const TextStyle(fontSize:16)),
    ]),
  );
}

class _TimeBlockCard extends StatelessWidget{
  final String title; final List<Habit> habits;
  const _TimeBlockCard({required this.title,required this.habits});
  @override Widget build(BuildContext ctx)=>Card(
    margin:const EdgeInsets.symmetric(horizontal:16,vertical:8),
    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
    elevation:1,
    child:Padding(
      padding:const EdgeInsets.all(12),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),
        if(habits.isEmpty)
          Center(child:Text('No Habits yet\ntap “+” to add', textAlign:TextAlign.center,
            style:TextStyle(color:Colors.purple.shade700,fontWeight:FontWeight.w600,fontSize:16)))
        else
          ...habits.map((h)=>InkWell(
            onTap:()=>Navigator.push(ctx,MaterialPageRoute(builder:(_)=>HabitFormScreen(
              original:h,presetName:h.name,presetIcon:h.icon,category:h.category))),
            child:Padding(
              padding:const EdgeInsets.symmetric(vertical:2),
              child:Text('${h.icon} ${h.name}',style:const TextStyle(fontSize:16)),
            ),
          )),
      ]),
    ),
  );
}

/// --- placeholder tabs ---
///class PlannerScreen extends StatelessWidget{ const PlannerScreen({super.key});
///  @override Widget build(BuildContext c)=>Center(child:Text('Planner Screen',style:Theme.of(c).textTheme.headlineMedium));}
class AnalyticsScreen extends StatelessWidget{ const AnalyticsScreen({super.key});
  @override Widget build(BuildContext c)=>Center(child:Text('Analytics Screen',style:Theme.of(c).textTheme.headlineMedium));}
class ProfileScreen extends StatelessWidget{ const ProfileScreen({super.key});
  @override Widget build(BuildContext c)=>const Scaffold(body:Center(child:Column(
    mainAxisAlignment:MainAxisAlignment.center,children:[Text('Profile Screen',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),SizedBox(height:20),SignOutButton()])));}

