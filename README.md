# Cadastro de Clientes

Aplicativo Flutter feito a partir do exemplo de Envio de Feedback da aula, para praticar formulários e envio de dados para uma API. Pode ser executado no Android e no Chrome.

## Como funciona

O usuário preenche nome, apelido, e-mail, telefone, endereço, CEP e cidade e toca em **Cadastrar**.

- Nome e e-mail são obrigatórios. Campos vazios ou preenchidos apenas com espaços impedem o envio.
- Os dados são enviados em JSON com `http.post` para `https://jsonplaceholder.typicode.com/users`.
- Durante o envio, o botão fica desabilitado e mostra um indicador de carregamento.
- Se a API responder com código `201`, o formulário é substituído por uma confirmação. Em caso de falha, aparece uma mensagem de erro.

A API é de testes: simula o cadastro, mas não salva os dados de verdade.

## Como executar

Com o Flutter instalado, abra o terminal na pasta `cadastro_clientes` e instale as dependências:

```sh
flutter pub get
```

Para abrir no Chrome:

```sh
flutter run -d chrome
```

Para Android, configure o SDK, inicie um emulador ou conecte um celular com depuração USB ativada. Depois execute:

```sh
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

Substitua `ID_DO_DISPOSITIVO` pelo identificador do Android listado no primeiro comando.

## Organização

- `lib/main.dart`: tela, validação e envio do cadastro.
- `assets/images/`: imagem de fundo do aplicativo.
- `android/` e `web/`: arquivos das plataformas utilizadas.
- `test/`: testes do formulário, validação e envio com respostas simuladas.
- `docs/print.png`: captura da tela.
- `pubspec.yaml`: dependências e registro da imagem de fundo.

Para executar os testes, use `flutter test`. As pastas `.dart_tool/` e `build/` são geradas automaticamente pelo Flutter.

## Tela do aplicativo

![Tela do formulário de cadastro de clientes](docs/print.png)
