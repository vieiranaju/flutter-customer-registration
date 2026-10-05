import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:cadastro_clientes/main.dart';

void main() {
  testWidgets('Formulário cabe em uma janela de 500 por 720', (tester) async {
    tester.view.physicalSize = const Size(500, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MeuApp());
    await tester.pumpAndSettle();

    final rolagem = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(rolagem.position.maxScrollExtent, 0);
    expect(find.byType(ElevatedButton).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  Future<void> preencher(WidgetTester tester) async {
    final valores = [
      ' Ana ',
      'Aninha',
      ' ana@example.com ',
      '11999999999',
      'Rua A, 10',
      '01001000',
      'São Paulo',
    ];
    for (var i = 0; i < valores.length; i++) {
      await tester.enterText(find.byType(TextField).at(i), valores[i]);
    }
    await tester.ensureVisible(find.byType(ElevatedButton));
  }

  void enviar(WidgetTester tester, MockClient client) {
    final botao = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    http.runWithClient(() => botao.onPressed!(), () => client);
  }

  testWidgets('Exibe sete campos e impede envio sem nome ou e-mail', (
    tester,
  ) async {
    await tester.pumpWidget(const MeuApp());
    expect(find.byType(TextField), findsNWidgets(7));
    for (final rotulo in [
      'Nome',
      'Apelido',
      'E-mail',
      'Telefone',
      'Endereço',
      'CEP',
      'Cidade',
    ]) {
      expect(find.text(rotulo), findsOneWidget);
    }
    var requisicoes = 0;
    final client = MockClient((request) async {
      requisicoes++;
      return http.Response('{}', 201);
    });
    for (final valores in [
      ['', ''],
      ['   ', 'ana@example.com'],
      ['Ana', '   '],
    ]) {
      await tester.enterText(find.byType(TextField).at(0), valores[0]);
      await tester.enterText(find.byType(TextField).at(2), valores[1]);
      enviar(tester, client);
      await tester.pump();
      expect(find.text('Preencha o nome e o e-mail.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }
    expect(requisicoes, 0);
  });

  testWidgets('Envia JSON, mostra carregamento e confirma código 201', (
    tester,
  ) async {
    await tester.pumpWidget(const MeuApp());
    await preencher(tester);
    final resposta = Completer<http.Response>();
    http.Request? requisicao;
    enviar(
      tester,
      MockClient((request) {
        requisicao = request;
        return resposta.future;
      }),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(requisicao!.method, 'POST');
    expect(
      requisicao!.url.toString(),
      'https://jsonplaceholder.typicode.com/users',
    );
    expect(requisicao!.headers['content-type'], contains('application/json'));
    expect(jsonDecode(requisicao!.body), {
      'nome': 'Ana',
      'apelido': 'Aninha',
      'email': 'ana@example.com',
      'telefone': '11999999999',
      'endereco': 'Rua A, 10',
      'cep': '01001000',
      'cidade': 'São Paulo',
    });
    resposta.complete(http.Response('{}', 201));
    await tester.pumpAndSettle();
    expect(find.text('Cliente cadastrado com sucesso!'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('Mostra erros e permite tentar novamente', (tester) async {
    await tester.pumpWidget(const MeuApp());
    await preencher(tester);
    enviar(tester, MockClient((request) async => http.Response('{}', 500)));
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível cadastrar. Tente novamente.'),
      findsOneWidget,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
    enviar(
      tester,
      MockClient((request) async => throw http.ClientException('Sem conexão')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível conectar. Verifique sua internet.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNWidgets(7));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
  });
}
