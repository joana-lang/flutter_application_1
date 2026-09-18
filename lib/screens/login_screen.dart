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
  //SMI: State Machine Input/ entrada de maquina de estado
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

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
}
