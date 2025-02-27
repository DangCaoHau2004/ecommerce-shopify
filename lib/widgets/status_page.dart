import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shopify/models/status_page.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({
    super.key,
    required this.type,
    required this.err,
  });

  final StatusPageEnum type;
  final String err;
  Widget loading(context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget error(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error: $e", style: Theme.of(context).textTheme.bodyLarge),
      ),
      body: Center(
        child: Text("Error: $e", style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  Widget noData(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "No data",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Center(
        child: Text("No data", style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return type == StatusPageEnum.loading
        ? loading(context)
        : type == StatusPageEnum.error
            ? error(context)
            : noData(context);
  }
}

class StatusPageWithOutScaffold extends StatelessWidget {
  const StatusPageWithOutScaffold({
    super.key,
    required this.type,
    required this.err,
  });

  final StatusPageEnum type;
  final String err;
  Widget loading(context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget error(context) {
    return Center(
      child: Text(
        "Error: $e",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget noData(context) {
    return Center(
      child: Text(
        "No data",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return type == StatusPageEnum.loading
        ? loading(context)
        : type == StatusPageEnum.error
            ? error(context)
            : noData(context);
  }
}

class StatusPageWithOutAppBar extends StatelessWidget {
  const StatusPageWithOutAppBar({
    super.key,
    required this.type,
    required this.err,
  });

  final StatusPageEnum type;
  final String err;
  Widget loading(context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget error(context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Error: $e",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget noData(context) {
    return Scaffold(
      body: Center(
        child: Text(
          "No data",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return type == StatusPageEnum.loading
        ? loading(context)
        : type == StatusPageEnum.error
            ? error(context)
            : noData(context);
  }
}
