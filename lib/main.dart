import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

List<Map<String, dynamic>> historialGlobal = [];
List<Map<String, dynamic>> medicamentosGlobal = [];

final FlutterLocalNotificationsPlugin notificationsPlugin 
=
    FlutterLocalNotificationsPlugin();

    void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(
    android: androidInit,
  );

  await notificationsPlugin.initialize(initSettings);

  runApp(const PoCMeApp());
}

void agregarHistorial({
  required String tipo,
  required String paciente,
  required String accion,
}) {
  historialGlobal.add({
    "tipo": tipo,
    "paciente": paciente,
    "accion": accion,
    "hora": DateTime.now().toString(),
  });

  guardarHistorial();
}
Future<void> guardarHistorial() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    "historial",
    jsonEncode(historialGlobal),
  );
} 
Future<void> cargarHistorial() async {
  final prefs = await SharedPreferences.getInstance();

  final datos = prefs.getString("historial");

  if (datos == null) return;

  historialGlobal = List<Map<String, dynamic>>.from(
    jsonDecode(datos),
  );
}
Future<void> limpiarHistorial() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove("historial");

  historialGlobal.clear();
}

  Future<void> mostrarNotificacion(String titulo, String cuerpo) async {
  const androidDetails = AndroidNotificationDetails(
    'canal_pocMe',
    'Notificaciones PoCMe',
    channelDescription: 'Alertas del sistema PocMe',
    importance: Importance.max,
    priority: Priority.high,
  );

  const generalNotificationDetails =
      NotificationDetails(android: androidDetails);

  await notificationsPlugin.show(
    0,
    titulo,
    cuerpo,
    generalNotificationDetails,
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usuarioController = TextEditingController();
  String? rolSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio de sesión"),
        backgroundColor: const Color(0xFF74B3CE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: usuarioController,
              decoration: const InputDecoration(
                labelText: "Nombre de usuario",
              ),
            ),

            const SizedBox(height: 20),

          DropdownButton<String>(
  hint: const Text("Selecciona rol"),
  value: rolSeleccionado,
  items: const [
    DropdownMenuItem(value: "pasante", child:
    Text("Pasante")),
    DropdownMenuItem(value: "Enfermero", child:
    Text("Enfermero")),
    DropdownMenuItem(value: "Doctor", child:
    Text("Doctor")),
          ],
          onChanged: (value) {
            setState(() {
              rolSeleccionado = value;
            });
            },
          ),

            const SizedBox(height: 30),

           ElevatedButton(
                onPressed: () async {
                  if (usuarioController.text.isEmpty ||
                      rolSeleccionado == null) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Completa los datos")),
                    );
                    return;
                  }

final prefs =
await SharedPreferences.getInstance();

  await prefs.setString(
  "usuario",
  usuarioController.text,
  );
  await prefs.setString(
    "rol",
    rolSeleccionado!,
    );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MenuScreen()),
                  );
                },
                child: const Text("Entrar"),
              ),
          ],
        ),
      ),
    );
  }
}


class PoCMeApp extends StatelessWidget {
  const PoCMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PoCMe',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFD6F3F4),
      ),
      home: const InicioScreen(),
    );
  }
}

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Image.asset(
  "assets/images/logo.png",
  height: 120,
),
              const SizedBox(height: 20),
              const Text(
                "PoCMe",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004346),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Position Changes and Medications",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF172A3A),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 250,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF74B3CE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Comenzar",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() =>
  _MenuScreenState();
  }
  class _MenuScreenState extends State<MenuScreen> {

  String usuario = "";
  String rol = "";
  int totalPacientes = 0;
  int medicamentosPendientes = 0;

  @override
  void initState() {
    super.initState();

    cargarUsuario();
  }

@override
void didChangeDependencies() {

  super.didChangeDependencies();

  cargarUsuario();

}

  Future<void> cargarUsuario() async {
  final prefs = await SharedPreferences.getInstance();

  final datosPacientes =
      prefs.getString("pacientes");

      final datosMedicamentos =
prefs.getString("medicamentos");

  int cantidad = 0;

  int pendientes = 0;

  if (datosPacientes != null) {
    cantidad = List<Map<String, dynamic>>.from(
      jsonDecode(datosPacientes),
    ).length;
  }

  if (datosMedicamentos != null) {

pendientes =
List<Map<String,dynamic>>.from(
jsonDecode(datosMedicamentos),
).where((m) {

return m["tomado"] == false;

}).length;

}

  setState(() {
    usuario = prefs.getString("usuario") ?? "";
    rol = prefs.getString("rol") ?? "";
    totalPacientes = cantidad;
    medicamentosPendientes =
pendientes;
  });
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("PoCMe"),
      backgroundColor: const Color(0xFF74B3CE),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          Card(
  elevation: 8,

  shape: RoundedRectangleBorder(
    borderRadius:
        BorderRadius.circular(20),
  ),

  child: ListTile(
    leading: const Icon(Icons.person),
    title: Text("Bienvenido $usuario"),
    subtitle: Text(
"Rol: $rol\n"
"Pacientes registrados: $totalPacientes\n"
"Medicamentos pendientes: $medicamentosPendientes",
),
  ),
),

          const SizedBox(height: 15),

          menuCard(
            context,
            Icons.bed,
            "Cambio de posición",
            const CambioPosicionScreen(),
          ),

          const SizedBox(height: 15),

          menuCard(
            context,
            Icons.medication,
            "Medicamentos",
            const MedicamentosScreen(),
          ),

          const SizedBox(height: 15),

          menuCard(
            context,
            Icons.person,
            "Paciente",
            const PacienteScreen(),
          ),

          const SizedBox(height: 15),

          menuCard(
            context,
            Icons.history,
            "Historial",
            const HistorialScreen(),
          ),
        ],
      ),
    ),
  );
}

  Widget menuCard(
    BuildContext context,
    IconData icon,
    String titulo,
    Widget pantalla,
  ) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFD6F3F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => pantalla),
          );
        },
        leading: Icon(
          icon,
          size: 40,
          color: const Color(0xFF004346),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

class CambioPosicionScreen extends StatefulWidget {
  const CambioPosicionScreen({super.key});

  @override
  State<CambioPosicionScreen> createState() =>
      _CambioPosicionScreenState();
}

class _CambioPosicionScreenState extends State<CambioPosicionScreen> {
Timer? _timer;

int segundos = 2 * 60 * 60;

bool enEjecucion = false;

List<Map<String, String>> posiciones = [

{
"nombre": "Decúbito supino",
"imagen":
"assets/images/decubito_supino.png",
},

{
"nombre":
"Decúbito lateral izquierdo",

"imagen":
"assets/images/decubito_lateral_izquierdo.png",
},

{
"nombre":
"Decúbito lateral derecho",

"imagen":
"assets/images/decubito_lateral_derecho.png",
},

{
"nombre":
"Sedestación izquierda",

"imagen":
"assets/images/sedestacion_izquierda.png",
},

{
"nombre":
"Sedestación derecha",

"imagen":
"assets/images/sedestacion_derecha.png",
},

];

int posicionActual = 0;

final player = AudioPlayer();

  String get tiempo {
    int h = segundos ~/ 3600;
    int m = (segundos % 3600) ~/ 60;
    int s = segundos % 60;

    return "${h.toString().padLeft(2, '0')}:"
           "${m.toString().padLeft(2, '0')}:"
           "${s.toString().padLeft(2, '0')}";

  }

  Color get colorTiempo {
    if (segundos <= 600) {
      return Colors.red; // 10 min o menos
      } else if (segundos <= 1800) {
        return Colors.orange; // 30 min o menos
        } else {
          return const Color(0xFF004346); // normal
          }
          }

   void iniciar() {
    if (segundos == 0) return;
    _timer?.cancel();

    setState(() {
      enEjecucion = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (segundos > 0) {
        setState(() {
          segundos--;
        });
      } 
      else {

        timer.cancel();
        
        player.play(
          AssetSource(
            'alarma.mp3'),
        );
        mostrarNotificacion(
          "Cambio de posicion",
           "Es momento de mover al paciente",
           );

        setState(() {
          enEjecucion = false;
        });
      }
    });
  }

  void reiniciar() {

    _timer?.cancel();

    player.stop();

      agregarHistorial(
  tipo: "Cambio",
  paciente: "Paciente",
  accion: posiciones[posicionActual]["nombre"]!,
);
setState(() {
  segundos= 2*60*60;
      posicionActual =
(posicionActual + 1)
%
posiciones.length;

      enEjecucion = false;
}); 
    
  }

  @override
  void dispose() {
    _timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambio de posición"),
        backgroundColor: const Color(0xFF74B3CE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [

            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(

                child: Image.asset(
                  posiciones[posicionActual]["imagen"]!,
                  height: 170,

                  fit: BoxFit.contain,
                ),
              ),
            ),
        
            const SizedBox(height: 25),

            const Text(
              "Próximo cambio en:",
              style: TextStyle(
                fontSize: 24,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(

  posiciones[posicionActual]
  ["nombre"]!,

  style: const TextStyle(

    fontSize: 22,

    fontWeight:
     FontWeight.bold,

    color: Color(0xFF004346),

  ),
),

            if (segundos <= 600)
            const Text(
              "Falta poco para el cambio",
              style: TextStyle(
                color:Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

const SizedBox(height: 15),

            Text(
              tiempo,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: colorTiempo,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: enEjecucion ? null : iniciar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF74B3CE),
                ),
                child: Text(
                  enEjecucion ? "En progreso..." : "Comenzar",
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: reiniciar,
                child: const Text(
  "Cambio realizado ✓",
),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MedicamentosScreen extends StatefulWidget {
  const MedicamentosScreen({super.key});

  @override
  State<MedicamentosScreen> createState() =>
      _MedicamentosScreenState();
}

class _MedicamentosScreenState
    extends State<MedicamentosScreen> {

  final List<Map<String, dynamic>> medicamentos = [];

  final nombreController =
      TextEditingController();

  final horaController =
      TextEditingController();

      String? pacienteSeleccionado;

      List<Map<String,dynamic>> pacientes = [];

      Timer? timerMedicamentos;

final playerMedicamento = AudioPlayer();

      List<Map<String, dynamic>> get medicamentosFiltrados {
  if (pacienteSeleccionado == null) {
    return medicamentos;

  }

  return medicamentos.where((m) {
    return m["paciente"] == pacienteSeleccionado;
  }).toList();
}

void iniciarRevisionMedicamentos() {
  timerMedicamentos?.cancel();

  timerMedicamentos =
      Timer.periodic(
    const Duration(seconds: 5),
    (timer) async {

      final ahora =
          TimeOfDay.now();

      final horaActual =
          "${ahora.hour.toString().padLeft(2, '0')}:"
          "${ahora.minute.toString().padLeft(2, '0')}";

      for (var med in medicamentos) {

        if (
            med["hora"] == horaActual &&
            med["tomado"] == false &&
            med["notificado"] != true
            ) {
            med["notificado"]=true;
guardarMedicamentos();

          print("SONANDO MEDICAMENTO");

          playerMedicamento.play(
            AssetSource(
              "alarma.mp3",
            ),
          );

          mostrarNotificacion(
            "Medicamento",
            "Hora de ${med["nombre"]}",
          );
        }
      }
    },
  );
}

      Future<void> guardarMedicamentos() async {

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setString(
    "medicamentos",

    jsonEncode(
      medicamentos,
    ),
  );
}
Future<void> cargarPacientes() async {
  final prefs = await SharedPreferences.getInstance();
  final datos = prefs.getString("pacientes");

  if (datos == null) return;

  setState(() {
    pacientes = List<Map<String, dynamic>>.from(jsonDecode(datos));
  });
}
Future<void> cargarMedicamentos() async {

  final prefs =
      await SharedPreferences.getInstance();

  final datos =
      prefs.getString(
        "medicamentos",
      );

  if (datos == null) return;

  setState(() {

    medicamentos.clear();

    medicamentos.addAll(
      List<Map<String, dynamic>>.from(
        jsonDecode(datos),
      ),
    );

    medicamentosGlobal =
        List<Map<String, dynamic>>.from(
      jsonDecode(datos),
    );

  });
}
@override
void initState() {
  super.initState();

  cargarMedicamentos();
  cargarPacientes();

  iniciarRevisionMedicamentos();
}

  void agregarMedicamento() {

    if (nombreController.text.isEmpty ||
        horaController.text.isEmpty ||
        pacienteSeleccionado == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
content: Text("Selecciona un paciente"),
            ),
            );
      return;
    }

    setState(() {

      medicamentos.add({

        "nombre":
            nombreController.text,

        "hora":
            horaController.text,

        "tomado":
            false,
            "notificado":false,
            "paciente": pacienteSeleccionado,
      });

      nombreController.clear();
      horaController.clear();

      guardarMedicamentos();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
                "Medicamentos"),

        backgroundColor:
            const Color(
                0xFF74B3CE),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
                20),

        child: 
        
        Column(
children: [

            TextField(
              controller: nombreController,
decoration: const InputDecoration(
                labelText: "Medicamento",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
  controller: horaController,

  readOnly: true,

  decoration: const InputDecoration(
    labelText: "Seleccionar hora",
    suffixIcon: Icon(
      Icons.access_time,
    ),
  ),

  onTap: () async {

    final hora = 
    await showTimePicker(

      context: context,

      initialTime:
          TimeOfDay.now(),
    );

if (!mounted) return;

    if (hora != null) {

     if (hora != null) {

     horaController.text =
"${hora.hour.toString().padLeft(2,'0')}:"
"${hora.minute.toString().padLeft(2,'0')}";
}
            }
            },
            ),
          
 const SizedBox(height: 20),
           
           DropdownButton<String>(
  hint: const Text("Selecciona paciente"),
  value: pacienteSeleccionado,
  isExpanded: true,
  items: pacientes.map<DropdownMenuItem<String>>((p) {
    return DropdownMenuItem<String>(
      value: p["nombre"].toString(),
      child: Text(p["nombre"].toString()),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      pacienteSeleccionado = value;


    });
  },
),

const SizedBox(height: 20),

            ElevatedButton(

              onPressed:
                  agregarMedicamento,

              child:
                  const Text(
                      "Agregar"),
            ),

            const SizedBox(
              height: 20,
            ),

            Expanded(

              child:
                  ListView.builder(

                itemCount:
                    medicamentosFiltrados.length,

                itemBuilder:
                    (_, i) {

                      final item = medicamentosFiltrados[i];
                       final realindex = medicamentos.indexOf(item);

                  return CheckboxListTile(

                    value: item["tomado"],
                    onChanged:
                        (v) {

                      setState(() {

                        medicamentos[realindex]
                            ["tomado"] = v ?? false;

                            if (v == true) {
  agregarHistorial(
    tipo: "Medicamento",
    paciente: item["paciente"] ?? "Sin asignar",
    accion: "Medicamento administrado: ${item["nombre"]}",
  );
}

                            guardarMedicamentos();

                      });
                    },

                    title: Text(
                      item["nombre"],

                      style: TextStyle(
                        decoration:
                        item["tomado"]
                        ? TextDecoration.lineThrough
                        : null,
                      ),
                    ),

                    subtitle: Text(

                      item["tomado"]
                      ? "Tomado"

                      :"Hora: ${item["hora"]}",
                    ),
                    secondary: IconButton(

  icon:
      const Icon(
          Icons.delete),

  color:
      Colors.red,

  onPressed: () async {

final eliminar =
await showDialog<bool>(

context: context,

builder: (context) {

return AlertDialog(

title:
const Text(
"Eliminar",
),

content:
const Text(
"¿Eliminar medicamento?",
),

actions: [

TextButton(

onPressed: () {
Navigator.pop(
context,
false,
);
},

child:
const Text(
"Cancelar",
),

),

TextButton(

onPressed: () {
Navigator.pop(
context,
true,
);
},

child:
const Text(
"Eliminar",
),

),

],

);

},
);

if (eliminar == true) {

setState(() {

medicamentos.removeAt(
realindex,
);

guardarMedicamentos();

});

}
},
),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
void dispose() {

  timerMedicamentos?.cancel();

  playerMedicamento.dispose();

  nombreController.dispose();

  horaController.dispose();

  super.dispose();
}
}

class PacienteScreen extends StatefulWidget {
  const PacienteScreen({super.key});

  @override
  State<PacienteScreen> createState() =>
      _PacienteScreenState();
}

class _PacienteScreenState
    extends State<PacienteScreen> {

  final nombreController =
      TextEditingController();

  final edadController =
      TextEditingController();

      final habitacionController =
      TextEditingController();

  final observacionesController =
      TextEditingController();

      List<Map<String, dynamic>> pacientes = [];

      Future<void> guardarDatos() async {
        

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setString(
    "nombre",
    nombreController.text,
  );

  await prefs.setString(
    "edad",
    edadController.text,
  );

  await prefs.setString(
    "habitacion",
    habitacionController.text,
  );

  await prefs.setString(
    "observaciones",
    observacionesController.text,
  );
}
Future<void> guardarPacientes() async {

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setString(
    "pacientes",
    jsonEncode(pacientes),
  );
}

Future<void> cargarPacientes() async {

  final prefs =
      await SharedPreferences.getInstance();

  final datos =
      prefs.getString("pacientes");

  if (datos == null) return;

  setState(() {

    pacientes = List<Map<String,dynamic>>.from(
      jsonDecode(datos)
    );

  });
}
Future<void> cargarDatos() async {

  final prefs =
      await SharedPreferences.getInstance();

  setState(() {

    nombreController.text =
        prefs.getString(
          "nombre",
        ) ??
        "";

    edadController.text =
        prefs.getString(
          "edad",
        ) ??
        "";

        habitacionController.text =
        prefs.getString(
          "habitacion",
        ) ??
        "";

    observacionesController.text =
        prefs.getString(
          "observaciones",
        ) ??
        "";
  });
}
@override
void initState() {

  super.initState();

  cargarDatos();

  cargarPacientes();
}

  @override
  void dispose() {

    nombreController.dispose();

    edadController.dispose();

    habitacionController.dispose();

    observacionesController.dispose();

    super.dispose();
  }
void editarPaciente(int index) async {
  nombreController.text = pacientes[index]["nombre"];
  edadController.text = pacientes[index]["edad"];
  habitacionController.text = pacientes[index]["habitacion"];
  observacionesController.text =
      pacientes[index]["observaciones"];

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Editar paciente"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre",
              ),
            ),

            TextField(
              controller: edadController,
              decoration: const InputDecoration(
                labelText: "Edad",
              ),
            ),

            TextField(
              controller: habitacionController,
              decoration: const InputDecoration(
                labelText: "Habitación",
              ),
            ),

            TextField(
              controller: observacionesController,
              decoration: const InputDecoration(
                labelText: "Observaciones",
              ),
            ),
          ],
        ),
      ),
      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancelar"),
        ),

        ElevatedButton(
          onPressed: () async {

            setState(() {
              pacientes[index] = {
                "nombre": nombreController.text,
                "edad": edadController.text,
                "habitacion": habitacionController.text,
                "observaciones":
                    observacionesController.text,
              };
            });

            await guardarPacientes();

            nombreController.clear();
edadController.clear();
habitacionController.clear();
observacionesController.clear();

            if (!mounted) return;

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Paciente actualizado"),
              ),
            );
          },
          child: const Text("Guardar"),
        ),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
                "Paciente"),

        backgroundColor:
            const Color(
                0xFF74B3CE),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
                20),
child:SingleChildScrollView(
        child: Column(

          children: [

            const Icon(
              Icons.person,
              size: 100,
              color:
                  Color(
                      0xFF508991),
            ),
        
            const SizedBox(
              height: 20,
            ),

            TextField(

              controller:
                  nombreController,

              decoration:
                  const InputDecoration(

                labelText:
                    "Nombre",
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(

              controller:
                  edadController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(

                labelText:
                    "Edad",
              ),
            ),

            const SizedBox(
  height: 15,
),

TextField(
  controller: habitacionController,
  decoration: const InputDecoration(
    labelText: "Habitación",
  ),
),

            const SizedBox(
              height: 15,
            ),

            TextField(

              controller:
                  observacionesController,

              maxLines: 4,

              decoration:
                  const InputDecoration(

                labelText:
                    "Observaciones",
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(
                          0xFF74B3CE),
                ),

                onPressed: () async {

                  final messenger =
                  ScaffoldMessenger.of(context);

if (
nombreController.text.trim().isEmpty ||
edadController.text.trim().isEmpty
) {
  messenger.showSnackBar(
    const SnackBar(
      content: Text(
        "Completa los campos",
      ),
    ),
  );
  return;
}

if (
int.tryParse(
edadController.text,
) == null
) {
  messenger.showSnackBar(
    const SnackBar(
      content: Text(
        "La edad debe ser un número",
      ),
    ),
  );
  return;
}
                 await guardarDatos();

                 final existe = pacientes.any(
  (p) => p["nombre"] == nombreController.text,
);

if (existe) {
  messenger.showSnackBar(
    const SnackBar(
      content: Text("Paciente ya registrado"),
    ),
  );
  return;
}
                 pacientes.add({
                  "nombre": nombreController.text,
                  "edad": edadController.text,
                  "habitacion": habitacionController.text,
                  "observaciones": observacionesController.text,
                  });

                  await guardarPacientes();
                      if (!mounted) return;

                      setState(() {
                        
                      });

                  messenger.showSnackBar(

                   const SnackBar(

                    content: 
                    Text(
                      "Paciente guardado",
                    ),
                    ),
                  );

                  nombreController.clear();

edadController.clear();

habitacionController.clear();

observacionesController.clear();
                },

                child:
                    const Text(
                        "Guardar"),
              ),
              ),
              const SizedBox(height: 20),

const Text(
  "Pacientes registrados",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: pacientes.length,
  itemBuilder: (context, index) {

    final paciente = pacientes[index];

   return Card(
  child: ListTile(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PerfilPacienteScreen(
            paciente: paciente,
          ),
        ),
      );
        },
  
    leading: const Icon(Icons.person),

    title: Text(
      paciente["nombre"] ?? "",
    ),

    subtitle: Text(
      "Edad: ${paciente["edad"]} | Hab: ${paciente["habitacion"]}",
    ),

    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        IconButton(
          icon: const Icon(
            Icons.edit,
            color: Colors.blue,
          ),
          onPressed: () {
            editarPaciente(index);
          },
        ),

        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () async {

            setState(() {
              pacientes.removeAt(index);
            });

            final prefs =
                await SharedPreferences.getInstance();

            await prefs.setString(
              "pacientes",
              jsonEncode(pacientes),
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Paciente eliminado"),
              ),
            );
            },
        ),

        ],
    ),
  ),
   );
   }
),

],
        ),
),
      ),
    );
    }
    }

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {

  @override
  void initState() {
    super.initState();

    cargarHistorial().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text("Historial"),
  backgroundColor: const Color(0xFF74B3CE),
  actions: [
    IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirmar"),
            content: const Text("¿Seguro que quieres borrar todo el historial?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  final messenger = 
                  ScaffoldMessenger.of(context);

                  await limpiarHistorial();

                  if (!mounted) return;

                  setState(() {});
                  Navigator.pop(context);

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Historial eliminado"),
                      ),
                  );
                },
                child: const Text("Borrar"),
              ),
            ],
          ),
        );
      },
    ),
  ],
),

      body: historialGlobal.isEmpty
          ? const Center(
              child: Text(
                "No hay registros",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: historialGlobal.length,
              itemBuilder: (context, index) {
                final item = historialGlobal[index];

                return ListTile(
                  leading: Icon(
                    item["tipo"] == "Medicamento"
                        ? Icons.medication
                        : Icons.bed,
                  ),
                  title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "Paciente: ${item["paciente"]}",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(item["accion"]),
  ],
),
                  subtitle: Text(
                  DateFormat(
                    'dd/MM/yyyy - hh:mm a',
                    ).format(
                      DateTime.parse(item["hora"]),
                      ),
                  ),
                );
              },
            ),
    );
  }
}
class PerfilPacienteScreen extends StatelessWidget {
  final Map<String, dynamic> paciente;

  const PerfilPacienteScreen({
    super.key,
    required this.paciente,
  });

  @override
  Widget build(BuildContext context) {
    final medicamentosPaciente =
medicamentosGlobal.where((m) {

return m["paciente"] ==
paciente["nombre"];

}).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          paciente["nombre"] ?? "Paciente",
        ),
        backgroundColor: const Color(0xFF74B3CE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.person,
              size: 100,
              color: Color(0xFF508991),
            ),

            const SizedBox(height: 20),

            Text(
              "Nombre: ${paciente["nombre"]}",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 10),

            Text(
              "Edad: ${paciente["edad"]}",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 10),

            Text(
              "Habitación: ${paciente["habitacion"]}",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 10),

            Text(
              "Observaciones: ${paciente["observaciones"] ?? ""}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 25),

const Text(
  "Medicamentos",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

if (medicamentosPaciente.isEmpty)

const Text(
  "Sin medicamentos asignados",
)

else

...medicamentosPaciente.map(
(m) {

return ListTile(

leading:
const Icon(
Icons.medication,
),

title:
Text(
m["nombre"],
),

subtitle:
Text(
"Hora: ${m["hora"]}",
),

);

},
),

Container(
  padding:
      const EdgeInsets.all(12),

  decoration:
      BoxDecoration(

    color:
        Colors.green.shade100,

    borderRadius:
        BorderRadius.circular(12),
  ),

  child:
      const Row(

    children: [

      Icon(
        Icons.circle,
        color: Colors.green,
      ),

      SizedBox(width: 10),

      Text(
        "Estado: Estable",
      ),
    ],
  ),
),
          ],
        ),
      ),
    );
  }
}