import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true; //control para mostrar o ocultar contraseña
  //crear el cerebro de la animacion
  StateMachineController? _controller;
  //SMI: State Machine Input/ entrada de maquina de estado, erebro de la animacion
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  //2.1. crear las variables para FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

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
                  },
                ),
              ),
              //para separar
              const SizedBox(height: 10),
              TextField(
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
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                        //para redondear
                        borderRadius: BorderRadius.circular(12))),
              ),

              const SizedBox(height: 10), //para salto de linea
              //Campo de texto para contraseña
              TextField(
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
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 2.4 liberar espacio en memoria
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}
