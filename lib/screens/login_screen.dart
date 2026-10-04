import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 importar el timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true; //control para mostrar o ocultar contraseña
  //crear el cerebro de la animacion

  //para recordas contraseña-------parte de la tarea
  //remember me
  bool _rememberMe = false;

  StateMachineController? _controller;
  //SMI: State Machine Input/ entrada de maquina de estado, erebro de la animacion
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  //3.2 variable del recorrido de la mirada
  SMINumber? _numLook;

  //3.3 Timer para detener la mirada al dejar de escribir
  Timer? _typingDebounce;

  //para aplicar el ----Lock UI interaction during animation to prevent rapid spam clicks
  //evitar spam
  bool _isLoginLocked = false;

  //2.1. crear las variables para FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  //4.1 Controllers que manipilan lo que ele ususario escribe
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  //errores para mostrarlo en la UI
  String? emailError;
  String? passError;

  //4.3 validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email); // hast.match viene en el examen
  }

  bool isValidPassword(pass) {
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  //4.4 Dar accion al boton
  void _onLogin() {
    //bloquear si ya se hizo el click ---- Si el botón ya está bloqueado, sal de _onLogin y no hagas nada.
    //evitar spam
    if (_isLoginLocked) return;
    //ativar bloqueo------- Acabo de presionar Login, así que ahora bloquéalo
    //evitar spam, lo de arriba

    setState(() {
      _isLoginLocked = true;
    });
    // de lo que escribio el usuario, quitar espacios en blanco
    // ignore: unused_local_variable
    final email = _emailCtrl.text.trim();
    // ignore: unused_local_variable
    final pass = _passCtrl.text;

    //4.6 evaluar los errores
    final eError = isValidEmail(email) ? null : "Invalid Email";
    final pError = isValidPassword(pass) ? null : "Invalid Password";

    //4.7 Avisar que hubo cambios
    setState(() {
      emailError = eError;
      passError = pError;
    });

    //para que la contraseña y el correo se eliminen de la interfaz despues de dar click en login
    //_emailCtrl.clear();
    //_passCtrl.clear();

    //4.8 cerrar teclao y bajar las manos
    FocusScope.of(context).unfocus(); //quita el foco
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.50;

    //4.9 Activar Triggers
    if (eError == null && pError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

  //2.2 Listeners (oyentes/chismosos)
  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        // Verificar que no sea nulo
        if (_isHandsUp != null) {
          // Manos abajo en el email
          _isHandsUp?.change(false);
          //3.4 Mirada neutra
          _numLook?.value = 50.0;
        }
      }
    });

    _passwordFocus.addListener(() {
      // Manos arriba en password
      _isHandsUp?.change(_passwordFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/login-bear.riv',
                  stateMachines: const ['Login Machine'],
                  //vincular animacion
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                      onStateChange: (stateMachineName, stateName) {
                        // Este es el "escucha" oficial de Rive que pide la tarea.
                        // 'stateName' te dice exactamente en qué estado está el oso (ej. 'idle', 'success', 'fail').

                        // Cuando el oso termina su animación y regresa al estado de reposo ('idle' o el estado inicial):
                        if (_isLoginLocked &&
                            (stateName == 'idle' || stateName == 'State 1')) {
                          if (!mounted) return;
                          setState(() {
                            _isLoginLocked =
                                false; // Desbloqueamos el botón exactamente al terminar
                          });
                        }
                      },
                    );

                    //verificar que inicio bien
                    if (_controller == null) return;

                    //agrega el controlador al escenario/tablero
                    artboard.addController(_controller!);
                    //vinvulamos variables
                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSuccess = _controller!.findSMI('trigSuccess');
                    _trigFail = _controller!.findSMI('trigFail');
                    //3.5 Vincular numlook
                    _numLook = _controller!.findSMI('numLook');
                  },
                ),
              ),
              //para separar
              const SizedBox(height: 10),
              TextField(
                //4.10 enlazar controles
                controller: _emailCtrl,
                focusNode: _emailFocus,
                onChanged: (value) {
                  if (_isHandsUp != null) {
                    //no tapes los ojos al ver email
                    _isHandsUp!.change(false);
                  }
                  // si es checking es nulo
                  if (_isChecking == null) return;
                  //activar el modo chismoso
                  _isChecking!.change(true);
                  //3.6 implementar numLook
                  //ajustes de limites del 0 al 100
                  //80 es la medida de calibracion
                  final look = (value.length / 40.0 * 100.0).clamp(0.0, 100.0);
                  //clamp es el rango, abrazadera
                  _numLook?.value = look;

                  //3.7 Debounce: si vuelve a teclear , reinicio el contador
                  //caneclar cualquier time existente
                  _typingDebounce?.cancel();
                  //crear nuevo timer
                  _typingDebounce = Timer(const Duration(seconds: 3), () {
                    //si se cierra la pantalla quita el contador
                    if (!mounted) return;
                    //mirada  neutra
                    _isChecking?.change(false);
                  });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    //4.11 Mostrar el texto de error
                    errorText: emailError,
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                        //para redondear
                        borderRadius: BorderRadius.circular(12))),
              ),

              const SizedBox(height: 10), //para salto de linea
              //Campo de texto para contraseña
              TextField(
                //4.10 enlazar controles
                controller: _passCtrl,
                //2.3 asignar foco al campo de txt
                focusNode: _passwordFocus,
                onChanged: (value) {
                  if (_isChecking != null) {
                    //no tapes los ojos al ver email
                    _isChecking!.change(false);
                  }
                  // si es checking es nulo
                  if (_isHandsUp == null) return;
                  //activar el modo chismoso
                  _isHandsUp!.change(true);
                },
                obscureText: _obscure,
                //keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  //4.11 Mostrar el texto de error
                  errorText: passError,
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                      onPressed: () {
                        //refrescar iconos
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      )),
                  border: OutlineInputBorder(
                    //para redondear
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              //aqui inicia el checkbox de remember pass---tarea
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Remember me'),
                    ],
                  ),
                  const Text(
                    'forgot password',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ), // aqui termina el boton de remember pass
              const SizedBox(height: 10),
              //boton de login
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                //se cambio esta linea de codigo ----s el onPressed que está dentro de MaterialButton, el botón rosa de login.
                //evitar spam
                onPressed: _isLoginLocked ? null : _onLogin,
                child: Text('login', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account"),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //4.15 liberar los controladores
    _emailCtrl.dispose();
    _passCtrl.dispose();
    // 2.4 liberar espacio en memoria
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel(); //3.9 eliminar el timer
    super.dispose();
  }
}
