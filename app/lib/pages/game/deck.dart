import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qeck/logic/connection/client.dart';
import 'package:qeck/logic/connection/logic.dart';
import 'package:qeck/logic/state.dart';
import 'package:qeck/pages/game/card.dart';

import 'cards.dart';

class DeckLocation {
  final GameDeck deck;
  final int? index;
  final int? seatIndex;

  DeckLocation(this.deck, this.index, this.seatIndex);
}

class CardLocation {
  final GameCard card;
  final int index;
  final DeckLocation location;

  CardLocation(this.card, this.index, this.location);
}

class GameDeckView extends StatelessWidget {
  final GameDeck deck;
  final int? index;
  final int? seatIndex;
  final ClientGameConnection connection;

  const GameDeckView({
    super.key,
    required this.deck,
    required this.index,
    required this.connection,
    required this.seatIndex,
  });

  @override
  Widget build(BuildContext context) {
    final firstCard = deck.cards.firstOrNull;
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (firstCard != null)
                Expanded(
                  child: InkWell(
                    onTap: () => showDialog(
                        context: context,
                        builder: (context) => CardDeckDialog(
                            deck: deck,
                            index: index,
                            connection: connection,
                            seatIndex: seatIndex)),
                    child: CardView(
                      card: firstCard,
                    ),
                  ),
                ),
              Row(children: [
                Expanded(
                    child: Text(
                  deck.name,
                  overflow: TextOverflow.ellipsis,
                )),
                MenuAnchor(
                  builder: (context, controller, child) => IconButton(
                    icon: const PhosphorIcon(PhosphorIconsLight.list),
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                  ),
                  menuChildren: [
                    MenuItemButton(
                      child: Text(AppLocalizations.of(context).moveCards),
                      onPressed: () {
                        final indexes = deck.cards.asMap().entries.map((e) {
                          if (index == null) {
                            return AvailableCardIndex(e.value);
                          }
                          if (seatIndex == null) {
                            return DeckCardIndex(e.key, index!);
                          }
                          return SeatCardIndex(e.key, index!, seatIndex!);
                        }).toList();
                        showDialog(
                          context: context,
                          builder: (context) => CardsOperationDialog(
                            cards: indexes,
                            connection: connection,
                          ),
                        );
                      },
                    ),
                    if (index != null) ...[
                      MenuItemButton(
                        child: Text(AppLocalizations.of(context).shuffle),
                        onPressed: () {
                          connection.shuffle(index!, seatIndex);
                        },
                      ),
                      MenuItemButton(
                        child: Text(AppLocalizations.of(context).putCards),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => PutCardsDialog(
                              deckIndex: index!,
                              seatIndex: seatIndex,
                              connection: connection,
                            ),
                          );
                        },
                      ),
                      MenuItemButton(
                        child:
                            Text(AppLocalizations.of(context).changeVisibility),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => ChangeVisibilityDeckDialog(
                              connection: connection,
                              index: index!,
                              seatIndex: seatIndex,
                            ),
                          );
                        },
                      ),
                      MenuItemButton(
                        child: Text(AppLocalizations.of(context).remove),
                        onPressed: () {
                          connection.removeDeck(index!, seatIndex);
                        },
                      ),
                    ],
                  ],
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class CardDeckDialog extends StatelessWidget {
  final GameDeck deck;
  final int? index;
  final int? seatIndex;
  final ClientGameConnection connection;

  const CardDeckDialog({
    super.key,
    required this.deck,
    required this.index,
    required this.connection,
    required this.seatIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: StreamBuilder<GameState>(
                      stream: connection.stateStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final state = snapshot.data;
                        var realDeck = deck;
                        if (seatIndex != null) {
                          realDeck = state!.seats[seatIndex!].decks[index!];
                        } else if (index != null) {
                          realDeck = state!.decks[index!];
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: realDeck.cards
                              .asMap()
                              .entries
                              .map((e) => InkWell(
                                    onTap: () {
                                      CardIndex cardIndex;
                                      if (index == null) {
                                        cardIndex = AvailableCardIndex(e.value);
                                      } else if (seatIndex == null) {
                                        cardIndex =
                                            DeckCardIndex(e.key, index!);
                                      } else {
                                        cardIndex = SeatCardIndex(
                                            e.key, index!, seatIndex!);
                                      }
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              CardsOperationDialog(
                                                  cards: [cardIndex],
                                                  connection: connection));
                                    },
                                    child: CardView(
                                      card: e.value,
                                    ),
                                  ))
                              .toList(),
                        );
                      }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddDeckView extends StatelessWidget {
  final ClientGameConnection connection;
  final int? seatIndex;
  const AddDeckView({super.key, required this.connection, this.seatIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showDialog(
            context: context,
            builder: (context) => AddDeckDialog(
              connection: connection,
              seatIndex: seatIndex,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              child: PhosphorIcon(PhosphorIconsLight.plus, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}

class AddDeckDialog extends StatelessWidget {
  final ClientGameConnection connection;
  final int? seatIndex;

  const AddDeckDialog({super.key, required this.connection, this.seatIndex});

  @override
  Widget build(BuildContext context) {
    GameDeck deck = const GameDeck();
    return AlertDialog(
      title: Text(AppLocalizations.of(context).addDeck),
      scrollable: true,
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).name,
              ),
              onChanged: (value) => deck = deck.copyWith(name: value),
            ),
            DropdownButtonFormField<DeckVisibility>(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).visibility,
              ),
              value: deck.visibility,
              items: DeckVisibility.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name),
                      ))
                  .toList(),
              onChanged: (value) =>
                  deck = deck.copyWith(visibility: value ?? deck.visibility),
            ),
            if (seatIndex != null)
              StatefulBuilder(
                builder: (context, setState) => Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<DeckVisibility>(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).ownVisibility,
                        ),
                        value: deck.ownVisibility,
                        items: DeckVisibility.values
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ))
                            .toList(),
                        onChanged: (value) => setState(
                            () => deck = deck.copyWith(ownVisibility: value)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const PhosphorIcon(PhosphorIconsLight.trash),
                      onPressed: () => setState(
                          () => deck = deck.copyWith(ownVisibility: null)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () {
            connection.addDeck(deck, seatIndex);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).create),
        ),
      ],
    );
  }
}

class ChangeVisibilityDeckDialog extends StatelessWidget {
  final ClientGameConnection connection;
  final int index;
  final int? seatIndex;

  const ChangeVisibilityDeckDialog({
    super.key,
    required this.connection,
    required this.index,
    this.seatIndex,
  });

  @override
  Widget build(BuildContext context) {
    var deck = seatIndex == null
        ? connection.state.decks[index]
        : connection.state.seats[seatIndex!].decks[index];
    var visibility = deck.visibility;
    var ownVisiblity = deck.ownVisibility;
    return AlertDialog(
      title: Text(AppLocalizations.of(context).changeVisibility),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<DeckVisibility>(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).visibility,
            ),
            value: visibility,
            items: DeckVisibility.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name),
                    ))
                .toList(),
            onChanged: (value) {
              visibility = value ?? visibility;
            },
          ),
          if (seatIndex != null)
            StatefulBuilder(
              builder: (context, setState) => Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DeckVisibility>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).ownVisibility,
                      ),
                      value: ownVisiblity,
                      items: DeckVisibility.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => ownVisiblity = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const PhosphorIcon(PhosphorIconsLight.trash),
                    onPressed: () => setState(() => ownVisiblity = null),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () {
            connection.changeVisibility(index, seatIndex, visibility);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).change),
        ),
      ],
    );
  }
}
