import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF526442),
          primary: const Color(0xFF526442),
          secondary: const Color(0xFFEBCDD3),
          surface: const Color(0xFFFFFBF8),
          onSurface: const Color(0xFF394331),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          isDense: true,
          fillColor: const Color(0xFFFFFBF8),
          prefixIconColor: const Color(0xFF697A59),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD5DAC6)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF526442),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const TelaCadastro(),
    );
  }
}

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  // Em telas menores, os pares voltam a ficar um abaixo do outro.
  Widget organizarCampos(Widget primeiro, Widget segundo) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [primeiro, const SizedBox(height: 12), segundo],
          );
        }
        return Row(
          children: [
            Expanded(child: primeiro),
            const SizedBox(width: 12),
            Expanded(child: segundo),
          ],
        );
      },
    );
  }

  final TextEditingController controladorNome = TextEditingController();
  final TextEditingController controladorApelido = TextEditingController();
  final TextEditingController controladorEmail = TextEditingController();
  final TextEditingController controladorTelefone = TextEditingController();
  final TextEditingController controladorEndereco = TextEditingController();
  final TextEditingController controladorCep = TextEditingController();
  final TextEditingController controladorCidade = TextEditingController();

  bool enviando = false;
  bool enviadoComSucesso = false;
  String? mensagemErro;

  @override
  void dispose() {
    controladorNome.dispose();
    controladorApelido.dispose();
    controladorEmail.dispose();
    controladorTelefone.dispose();
    controladorEndereco.dispose();
    controladorCep.dispose();
    controladorCidade.dispose();
    super.dispose();
  }

  Future<void> cadastrarCliente() async {
    // Não faz a requisição se nome ou e-mail estiverem vazios.
    if (controladorNome.text.trim().isEmpty ||
        controladorEmail.text.trim().isEmpty) {
      setState(() {
        mensagemErro = 'Preencha o nome e o e-mail.';
      });
      return;
    }

    setState(() {
      enviando = true;
      mensagemErro = null;
    });

    final url = Uri.parse('https://jsonplaceholder.typicode.com/users');

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': controladorNome.text.trim(),
          'apelido': controladorApelido.text.trim(),
          'email': controladorEmail.text.trim(),
          'telefone': controladorTelefone.text.trim(),
          'endereco': controladorEndereco.text.trim(),
          'cep': controladorCep.text.trim(),
          'cidade': controladorCidade.text.trim(),
        }),
      );

      if (!mounted) return;

      if (resposta.statusCode == 201) {
        setState(() {
          enviando = false;
          enviadoComSucesso = true;
        });
      } else {
        setState(() {
          enviando = false;
          mensagemErro = 'Não foi possível cadastrar. Tente novamente.';
        });
      }
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        enviando = false;
        mensagemErro = 'Não foi possível conectar. Verifique sua internet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: const Text(
          'Cadastro de Clientes',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF4E2E5),
        foregroundColor: const Color(0xFF394331),
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/spring_aesthetic.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: ConstrainedBox(
                // Mantém o formulário confortável de ler também no computador.
                constraints: const BoxConstraints(maxWidth: 680),
                child: Card(
                  color: const Color(0xD9FFFBF8), // 85% de opacidade.
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFEBCDD3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: enviadoComSucesso
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 32),
                              Icon(
                                Icons.check_circle_outline,
                                size: 72,
                                color: Color(0xFF526442),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Cliente cadastrado com sucesso!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Os dados foram enviados. Obrigado por preencher o cadastro.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF696458),
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 32),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_add_alt_1_rounded,
                                    size: 24,
                                    color: Color(0xFF526442),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Novo cliente',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Preencha os dados. Nome e e-mail são obrigatórios.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF696458),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'Dados pessoais',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              organizarCampos(
                                TextField(
                                  controller: controladorNome,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                ),
                                TextField(
                                  controller: controladorApelido,
                                  decoration: const InputDecoration(
                                    labelText: 'Apelido',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'Contato',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              organizarCampos(
                                TextField(
                                  controller: controladorEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'E-mail',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                TextField(
                                  controller: controladorTelefone,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefone',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'Localização',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: controladorEndereco,
                                decoration: const InputDecoration(
                                  labelText: 'Endereço',
                                  prefixIcon: Icon(Icons.home_outlined),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: controladorCep,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'CEP',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: controladorCidade,
                                      decoration: const InputDecoration(
                                        labelText: 'Cidade',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: enviando ? null : cadastrarCliente,
                                child: enviando
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Cadastrar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                              if (mensagemErro != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    mensagemErro!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFB3261E),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
