import 'package:flutter/material.dart'; // Import de la bibliothèque Flutter pour les widgets
import 'package:provider/provider.dart'; // Import de la bibliothèque Provider pour la gestion de l'état

// Point d'entrée principal de l'application
void main() {
  runApp(MyApp()); // Exécution de l'application MyApp
}

// Classe principale de l'application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(), // Création d'une instance de TaskProvider
      child: MaterialApp(
        title: 'Todo App', // Titre de l'application
        home: TaskScreen(), // Écran d'accueil de l'application
        debugShowCheckedModeBanner: false, // Désactivation de la bannière de débogage
        routes: {
          FilteredTasksScreen.routeName: (context) => FilteredTasksScreen(), // Route pour l'écran des tâches filtrées
          AddTaskScreen.routeName: (context) => AddTaskScreen(), // Route pour l'écran d'ajout de tâche
        },
      ),
    );
  }
}

// Classe fournissant les données et les méthodes pour gérer les tâches
class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [
    Task(name: 'Tâche 1', color: Colors.grey, status: 'À faire'),
    Task(name: 'Tâche 2', color: Colors.green, status: 'En cours'),
    Task(name: 'Tâche 3', color: Colors.red, status: 'Bogue'),
    Task(name: 'Tâche 4', color: Colors.red, status: 'Bogue'),
    Task(name: 'Tâche 5', color: Colors.grey, status: 'À faire'),
    Task(name: 'Tâche 6', color: Colors.grey, status: 'À faire'),
    Task(name: 'Tâche 7', color: Colors.lightBlue, status: 'Terminé'),
  ];

  List<Task> _filteredTasks = []; // Liste des tâches filtrées

  List<Task> get tasks => _tasks; // Getter pour la liste des tâches
  List<Task> get filteredTasks => _filteredTasks; // Getter pour la liste des tâches filtrées

  void addTask(Task task) {
    _tasks.add(task); // Ajout d'une tâche à la liste
    notifyListeners(); // Notification des auditeurs
  }

  void updateTask(int index, Task task) {
    _tasks[index] = task; // Mise à jour d'une tâche à l'index donné
    notifyListeners(); // Notification des auditeurs
  }

  void applyFilters(List<String> filters) {
    _filteredTasks =
        _tasks.where((task) => filters.contains(task.status)).toList(); // Application des filtres sur les tâches
    notifyListeners(); // Notification des auditeurs
  }
}

// Classe représentant une tâche
class Task {
  String name;
  Color color;
  String status;
  String description; // Description de la tâche

  Task({required this.name, required this.color, required this.status, this.description = ''});
}

// Écran principal de l'application affichant la liste des tâches
class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'), // Titre de la barre d'application
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list), // Icône de filtre
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FilterDialog(), // Affichage de la boîte de dialogue de filtre
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return TaskList(taskProvider: taskProvider); // Affichage de la liste des tâches
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddTaskScreen.routeName).then((value) {
            Provider.of<TaskProvider>(context, listen: false).notifyListeners(); // Mise à jour de l'état après ajout de tâche
          });
        },
        child: Icon(Icons.add), // Icône pour ajouter une tâche
      ),
    );
  }
}

// Widget affichant la liste des tâches
class TaskList extends StatelessWidget {
  final TaskProvider taskProvider;

  TaskList({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: taskProvider.tasks.length, // Nombre d'éléments dans la liste
      itemBuilder: (context, index) {
        return TaskTile(
          task: taskProvider.tasks[index],
          index: index,
        );
      },
    );
  }
}

// Widget affichant une tuile de tâche
class TaskTile extends StatelessWidget {
  final Task task;
  final int index;

  TaskTile({required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: task.color, // Couleur de l'avatar
      ),
      title: Text(task.name), // Nom de la tâche
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => TaskDialog(
            task: task,
            index: index,
          ),
        );
      },
    );
  }
}

// Boîte de dialogue pour modifier une tâche
class TaskDialog extends StatefulWidget {
  final Task task;
  final int index;

  TaskDialog({required this.task, required this.index});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late Color _color;
  late String _status;
  late String _description;

  @override
  void initState() {
    super.initState();
    _name = widget.task.name; // Initialisation du nom
    _color = widget.task.color; // Initialisation de la couleur
    _status = widget.task.status; // Initialisation du statut
    _description = widget.task.description; // Initialisation de la description
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifier la tâche'), // Titre de la boîte de dialogue
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(labelText: 'Nom de la tâche'), // Champ pour le nom de la tâche
              onSaved: (value) {
                _name = value!;
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<Color>(
              value: _color,
              items: [
                DropdownMenuItem(
                  child: Text('Gris'),
                  value: Colors.grey,
                ),
                DropdownMenuItem(
                  child: Text('Vert'),
                  value: Colors.green,
                ),
                DropdownMenuItem(
                  child: Text('Rouge'),
                  value: Colors.red,
                ),
                DropdownMenuItem(
                  child: Text('Bleu clair'),
                  value: Colors.lightBlue,
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _color = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Couleur de la tâche'), // Champ pour la couleur de la tâche
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _status,
              items: [
                DropdownMenuItem(
                  child: Text('À faire'),
                  value: 'À faire',
                ),
                DropdownMenuItem(
                  child: Text('En cours'),
                  value: 'En cours',
                ),
                DropdownMenuItem(
                  child: Text('Terminé'),
                  value: 'Terminé',
                ),
                DropdownMenuItem(
                  child: Text('Bogue'),
                  value: 'Bogue',
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Statut de la tâche'), // Champ pour le statut de la tâche
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: _description,
              decoration: InputDecoration(labelText: 'Description de la tâche'), // Champ pour la description de la tâche
              onSaved: (value) {
                _description = value!;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fermeture de la boîte de dialogue
          },
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final updatedTask = Task(
                name: _name,
                color: _color,
                status: _status,
                description: _description,
              );
              Provider.of<TaskProvider>(context, listen: false)
                  .updateTask(widget.index, updatedTask); // Mise à jour de la tâche
              Navigator.of(context).pop(); // Fermeture de la boîte de dialogue
            }
          },
          child: Text('Modifier'),
        ),
      ],
    );
  }
}

// Boîte de dialogue pour filtrer les tâches
class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final List<String> _filters = ['À faire', 'En cours', 'Terminé', 'Bogue']; // Liste des filtres disponibles
  final Map<String, bool> _filterSelection = {
    'À faire': false,
    'En cours': false,
    'Terminé': false,
    'Bogue': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filtrer par'), // Titre de la boîte de dialogue
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _filters.map((filter) {
          return CheckboxListTile(
            title: Text(filter),
            value: _filterSelection[filter]!,
            onChanged: (value) {
              setState(() {
                _filterSelection[filter] = value!;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fermeture de la boîte de dialogue
          },
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            List<String> selectedFilters =
            _filters.where((filter) => _filterSelection[filter]!).toList();
            Provider.of<TaskProvider>(context, listen: false)
                .applyFilters(selectedFilters); // Application des filtres
            Navigator.of(context).pop(); // Fermeture de la boîte de dialogue
            Navigator.of(context).pushNamed(FilteredTasksScreen.routeName); // Navigation vers l'écran des tâches filtrées
          },
          child: Text('Appliquer'),
        ),
      ],
    );
  }
}

// Écran affichant les tâches filtrées
class FilteredTasksScreen extends StatelessWidget {
  static const routeName = '/tâches-filtrées';

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.filteredTasks; // Récupération des tâches filtrées
    return Scaffold(
      appBar: AppBar(
        title: Text('Tâches Filtrées'), // Titre de la barre d'application
      ),
      body: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          return TaskTile(
            task: filteredTasks[index],
            index: taskProvider.tasks.indexOf(filteredTasks[index]), // Affichage des tâches filtrées
          );
        },
      ),
    );
  }
}

// Écran pour ajouter une nouvelle tâche
class AddTaskScreen extends StatefulWidget {
  static const routeName = '/ajouter-tâche';

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _taskName = '';
  String _taskDescription = '';
  String _taskStatus = 'À faire';
  Color _taskColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une tâche'), // Titre de la barre d'application
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // Fermeture de l'écran
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _taskStatus,
                items: [
                  DropdownMenuItem(
                    child: Text('À faire'),
                    value: 'À faire',
                  ),
                  DropdownMenuItem(
                    child: Text('En cours'),
                    value: 'En cours',
                  ),
                  DropdownMenuItem(
                    child: Text('Terminé'),
                    value: 'Terminé',
                  ),
                  DropdownMenuItem(
                    child: Text('Bogue'),
                    value: 'Bogue',
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _taskStatus = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Statut'), // Champ pour le statut de la tâche
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom de la tâche'), // Champ pour le nom de la tâche
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un nom de tâche';
                  }
                  return null;
                },
                onSaved: (value) {
                  _taskName = value!;
                },
              ),
              TextFormField(
                maxLines: 3,
                decoration:
                InputDecoration(labelText: 'Description de la tâche'), // Champ pour la description de la tâche
                onSaved: (value) {
                  _taskDescription = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final taskProvider =
                    Provider.of<TaskProvider>(context, listen: false);
                    taskProvider.addTask(Task(
                      name: _taskName,
                      color: _taskColor,
                      status: _taskStatus,
                      description: _taskDescription,
                    )); // Ajout de la nouvelle tâche
                    Navigator.pop(context); // Fermeture de l'écran
                  }
                },
                child: Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Fermeture de l'écran
        },
        child: Icon(Icons.close, color: Colors.white), // Icône de fermeture
        backgroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
