import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ====================== DATA MODEL ======================
class Habit {
  String id;
  String name;
  String icon;       
  String category;
  String description;
  int minTime;       
  int maxTime;       
  DateTime startDate;
  TimeOfDay targetTime;
  List<int> days;    

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.description,
    required this.minTime,
    required this.maxTime,
    required this.startDate,
    required this.targetTime,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'category': category,
        'description': description,
        'minTime': minTime,
        'maxTime': maxTime,
        'startDate': Timestamp.fromDate(startDate),
        'targetTime':
            '${targetTime.hour.toString().padLeft(2, '0')}:${targetTime.minute.toString().padLeft(2, '0')}',
        'days': days,
      };

  factory Habit.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final split = (d['targetTime'] as String).split(':');
    return Habit(
      id: doc.id,
      name: d['name'] ?? '',
      icon: d['icon'] ?? '',
      category: d['category'] ?? '',
      description: d['description'] ?? '',
      minTime: d['minTime'] ?? 0,
      maxTime: d['maxTime'] ?? 0,
      startDate: (d['startDate'] as Timestamp).toDate(),
      targetTime: TimeOfDay(hour: int.parse(split[0]), minute: int.parse(split[1])),
      days: List<int>.from(d['days'] ?? []),
    );
  }
}

/// ====================== FIRESTORE SERVICE ======================
class HabitService {
  final _db  = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> createHabit(Habit h) async => _db
      .collection('users').doc(_uid).collection('habits')
      .add(h.toJson());

  Future<void> updateHabit(Habit h) async => _db
      .collection('users').doc(_uid).collection('habits')
      .doc(h.id).update(h.toJson());

  /// Stream all habits that include the given weekday (0=Mon … 6=Sun)
  Stream<List<Habit>> habitsForDay(int weekdayIndex) => _db
      .collection('users').doc(_uid).collection('habits')
      .where('days', arrayContains: weekdayIndex)
      .snapshots()
      .map((snap) => snap.docs.map(Habit.fromDoc).toList());
   /// One‑shot fetch of habits for an exact calendar date
  Future<List<Habit>> habitsOn(DateTime date) async {
    final key = DateTime(date.year, date.month, date.day);
    final qs = await _db
        .collection('users').doc(_uid).collection('habits')
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(key))
        .get();
    final all = qs.docs.map(Habit.fromDoc).toList();
    final wd = date.weekday - 1;
    return all.where((h) => h.days.contains(wd)).toList();
  }
}

/// ====================== PRESET DATA ============================
const presetHabits = {
  'Sports': [
    {'name': 'Walk',      'icon': '🚶‍♂️'},
    {'name': 'Exercise',  'icon': '🏋️‍♂️'},
    {'name': 'Run',       'icon': '🏃‍♂️'},
    {'name': 'Stretch',   'icon': '🤸‍♀️'},
    {'name': 'Swim',      'icon': '🏊‍♂️'},
    {'name': 'Cycling',   'icon': '🚴‍♂️'},
  ],
  'Health': [
    {'name': 'Drink Water', 'icon': '💧'},
    {'name': 'Sleep Early', 'icon': '😴'},
    {'name': 'Healthy Meal','icon': '🥗'},
  ],
  'Thoughts': [
    {'name': 'Meditate', 'icon': '🧘‍♂️'},
    {'name': 'Read Book','icon': '📚'},
    {'name': 'Journal',  'icon': '📓'},
  ],
};

/// ====================== ADD / EDIT FLOW ========================
class AddHabitsScreen extends StatelessWidget {
  const AddHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add Habits')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CategoryTile(
              title: 'Custom Habits',
              trailing: const Icon(Icons.add),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HabitFormScreen(
                    original: null,
                    presetName: '',
                    presetIcon: '✅',
                    category: 'Custom',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...presetHabits.entries.map(
              (e) => _ExpandableCategory(title: e.key, habits: e.value),
            ),
          ],
        ),
      );
}

/// -------- category helpers ----------
class _CategoryTile extends StatelessWidget {
  final String title; final Widget? trailing; final VoidCallback onTap;
  const _CategoryTile({required this.title,this.trailing,required this.onTap});
  @override
  Widget build(BuildContext ctx) => Card(
        color: Colors.grey.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Center(child: Text(title, style: const TextStyle(fontSize: 18))),
          trailing: trailing,
          onTap: onTap,
        ),
      );
}

class _ExpandableCategory extends StatefulWidget {
  final String title; final List<Map<String,String>> habits;
  const _ExpandableCategory({required this.title, required this.habits});
  @override _ExpandableCategoryState createState()=>_ExpandableCategoryState();
}
class _ExpandableCategoryState extends State<_ExpandableCategory>{
  bool _open=false;
  @override
  Widget build(BuildContext context)=>Column(children:[
    _CategoryTile(
      title: widget.title,
      trailing: Icon(_open?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down),
      onTap: ()=>setState(()=>_open=!_open),
    ),
    if(_open) ...widget.habits.map((h)=>ListTile(
      leading: Text(h['icon']!,style:const TextStyle(fontSize:20)),
      title: Text(h['name']!),
      trailing: const Icon(Icons.chevron_right),
      onTap: ()=>Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_)=>HabitFormScreen(
            original: null,
            presetName: h['name']!,
            presetIcon: h['icon']!,
            category: widget.title,
          ),
        ),
      ),
    )),
  ]);
}

/// ====================== HABIT FORM  (add / edit) ===============
class HabitFormScreen extends StatefulWidget {
  final Habit? original;
  final String presetName;
  final String presetIcon;
  final String category;
  const HabitFormScreen({
    required this.original,
    required this.presetName,
    required this.presetIcon,
    required this.category,
    super.key,
  });
  @override State<HabitFormScreen> createState()=>_HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen>{
  final _formKey=GlobalKey<FormState>();
  late TextEditingController _nameC,_descC;
  int _minTime=10,_maxTime=30;
  DateTime _startDate=DateTime.now();
  TimeOfDay _target=const TimeOfDay(hour:5,minute:0);
  List<int> _daysSel=[];
  @override
  void initState(){
    super.initState();
    final h=widget.original;
    _nameC=TextEditingController(
      text: h!=null
          ? h.name
          : (widget.presetName.isEmpty?'':'${widget.presetIcon} ${widget.presetName}'));
    _descC=TextEditingController(text:h?.description??'');
    _minTime=h?.minTime??10;
    _maxTime=h?.maxTime??30;
    _startDate=h?.startDate??DateTime.now();
    _target=h?.targetTime??const TimeOfDay(hour:5,minute:0);
    _daysSel=h?.days??[];
  }

  /// --------------- UI ---------------
  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar: AppBar(title: Text(widget.original==null?'New Habit':'Edit Habit')),
    body:Padding(
      padding:const EdgeInsets.all(16),
      child:Form(
        key:_formKey,
        child:ListView(children:[
          const Text('Name',style:TextStyle(fontWeight:FontWeight.bold)),
          TextFormField(controller:_nameC,
            validator:(v)=>v==null||v.trim().isEmpty?'Required':null),
          const SizedBox(height:16),
          const Text('Description',style:TextStyle(fontWeight:FontWeight.bold)),
          TextFormField(controller:_descC,maxLines:2),
          const SizedBox(height:24),
          const Text('Repeat on',style:TextStyle(fontWeight:FontWeight.bold)),
          Wrap(
            spacing:4,
            children:List.generate(7,(i){
              const lbl=['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
              final sel=_daysSel.contains(i);
              return ChoiceChip(
                label:Text(lbl[i]),
                selected:sel,
                onSelected:(v){setState(()=> v?_daysSel.add(i):_daysSel.remove(i));},
              );
            }),
          ),
          const SizedBox(height:24),
          _pickRow('Minimum time',_minTime,(int? v){if(v!=null)setState(()=>_minTime=v);} ),
          _pickRow('Maximum time',_maxTime,(int? v){if(v!=null)setState(()=>_maxTime=v);} ),
          _dateRow('Start date',_startDate,() async{
            final p=await showDatePicker(
              context:context,
              initialDate:_startDate,
              firstDate:DateTime.now().subtract(const Duration(days:365)),
              lastDate:DateTime.now().add(const Duration(days:365)));
            if(p!=null)setState(()=>_startDate=p);
          }),
          _timeRow('Target time',_target,() async{
            final p=await showTimePicker(context:context,initialTime:_target);
            if(p!=null)setState(()=>_target=p);
          }),
          const SizedBox(height:40),
          ElevatedButton(
            style:ElevatedButton.styleFrom(
              padding:const EdgeInsets.symmetric(vertical:14),
              backgroundColor:Colors.indigoAccent,
              shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30))),
            onPressed:_save,
            child:Text(widget.original==null?'Save':'Update',style:const TextStyle(fontSize:18)),
          ),
        ]),
      ),
    ),
  );

  Widget _pickRow(String label,int value,ValueChanged<int?> onChanged)=>Row(
    mainAxisAlignment:MainAxisAlignment.spaceBetween,
    children:[
      Expanded(child:Text(label)),
      DropdownButton<int>(
        value:value,
        items:List.generate(120,(i)=>(i+1)*5)
          .map((e)=>DropdownMenuItem(value:e,child:Text(e.toString()))).toList(),
        onChanged:onChanged,
      ),
    ],
  );

  Widget _dateRow(String label,DateTime date,VoidCallback onTap)=>InkWell(
    onTap:onTap,
    child:Padding(
      padding:const EdgeInsets.symmetric(vertical:12),
      child:Row(
        mainAxisAlignment:MainAxisAlignment.spaceBetween,
        children:[
          Text(label),
          Text('${date.month.toString().padLeft(2,'0')}/${date.day.toString().padLeft(2,'0')}/${date.year}',
              style:const TextStyle(color:Colors.purple,fontWeight:FontWeight.bold)),
        ],
      ),
    ),
  );

  Widget _timeRow(String label,TimeOfDay t,VoidCallback onTap)=>InkWell(
    onTap:onTap,
    child:Padding(
      padding:const EdgeInsets.symmetric(vertical:12),
      child:Row(
        mainAxisAlignment:MainAxisAlignment.spaceBetween,
        children:[
          Text(label),
          Text(t.format(context),
              style:const TextStyle(color:Colors.purple,fontWeight:FontWeight.bold)),
        ],
      ),
    ),
  );

  /// --------------- SAVE ---------------
  Future<void> _save() async{
    if(!_formKey.currentState!.validate()) return;
    final habit=Habit(
      id:widget.original?.id ?? '',
      name:_nameC.text.trim(),
      icon:widget.original?.icon ?? widget.presetIcon,
      category:widget.category,
      description:_descC.text.trim(),
      minTime:_minTime,
      maxTime:_maxTime,
      startDate:_startDate,
      targetTime:_target,
      days:_daysSel,
    );
    final service=HabitService();
    if(widget.original==null){
      await service.createHabit(habit);
    }else{
      await service.updateHabit(habit);
    }
    if(mounted)Navigator.pop(context);
  }
}