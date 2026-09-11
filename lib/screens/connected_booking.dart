import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/booking_api.dart';
import '../widgets/kiosk_chrome.dart';
import 'kiosk_shell.dart';

String errorText(Object error) => error is BookingApiException
    ? error.message
    : '요청을 처리하지 못했습니다. 잠시 후 다시 시도해 주세요.';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({required this.onExit, required this.api, super.key});
  final VoidCallback onExit;
  final BookingRepository api;
  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final draft = ReservationDraft();
  BookingConfig? config;
  List<TimeSlot> slots = [];
  int step = 0;
  bool loading = true;
  bool submitting = false;
  bool uncertain = false;
  int generation = 0;
  String? message;
  String requestId = newRequestId();
  Reservation? reservation;
  bool get canContinue =>
      !loading &&
      !submitting &&
      config != null &&
      switch (step) {
        0 => draft.time != null,
        1 => draft.time != null,
        2 => RegExp(r'^010\d{8}$').hasMatch(draft.phone),
        3 => true,
        _ => false,
      };
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      loading = true;
      message = null;
    });
    try {
      final value = await widget.api.config();
      if (!mounted) return;
      if (value.dates.isEmpty) {
        throw const BookingApiException('예약 가능한 날짜가 없습니다.');
      }
      config = value;
      draft.price60 = value.price60;
      draft.price90 = value.price90;
      draft.storeName = value.storeName;
      await _loadSlots();
    } catch (error) {
      if (mounted) {
        setState(() {
          loading = false;
          message = errorText(error);
        });
      }
    }
  }

  Future<void> _loadSlots() async {
    final current = ++generation;
    setState(() {
      loading = true;
      message = null;
      slots = [];
    });
    try {
      final value = await widget.api
          .availability(config!.dates[draft.dateIndex].iso, draft.duration);
      if (!mounted || current != generation) return;
      setState(() {
        slots = value;
        loading = false;
        if (draft.time != null &&
            !slots.any((slot) =>
                slot.time == draft.time &&
                slot.enabled &&
                (draft.bayNumber == null ||
                    slot.availableBays.contains(draft.bayNumber)))) {
          draft.time = null;
          draft.bayNumber = null;
          step = 0;
          message = '선택한 타석 또는 시간이 마감되었습니다. 시작 시간과 타석을 다시 선택해 주세요.';
        }
      });
    } catch (error) {
      if (mounted && current == generation) {
        setState(() {
          loading = false;
          draft.time = null;
          draft.bayNumber = null;
          message = errorText(error);
        });
      }
    }
  }

  Future<void> _exit() async {
    if (submitting || uncertain) return;
    final exit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('예약을 그만할까요?'),
                content: const Text('선택한 내용은 저장되지 않습니다.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('계속 예약하기')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('첫 화면으로'))
                ]));
    if (exit == true && mounted) widget.onExit();
  }

  void _back() {
    if (submitting || uncertain) return;
    requestId = newRequestId();
    if (step == 0) {
      _exit();
    } else {
      setState(() => step--);
    }
  }

  Future<void> _next() async {
    if (!canContinue) return;
    if (step < 3) {
      setState(() => step++);
      return;
    }
    setState(() {
      submitting = true;
      message = null;
    });
    try {
      final result = await widget.api
          .create(draft, config!.dates[draft.dateIndex].iso, requestId);
      if (mounted) {
        setState(() {
          reservation = result;
          uncertain = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        message = errorText(error);
        uncertain = error is! BookingApiException ||
            error.status == null ||
            error.status! >= 500;
      });
      if (error is BookingApiException && error.status == 409) {
        final conflictMessage = error.message;
        requestId = newRequestId();
        draft.time = null;
        draft.bayNumber = null;
        step = 0;
        await _initialize();
        if (mounted) setState(() => message = conflictMessage);
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reservation != null) {
      return BookingSuccessScreen(
          draft: draft, reservation: reservation!, onDone: widget.onExit);
    }
    return Column(children: [
      KioskHeader(onHome: _exit),
      BookingProgress(currentStep: step),
      if (loading || submitting) const LinearProgressIndicator(),
      if (message != null)
        Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text(message!, textAlign: TextAlign.center),
              if (uncertain)
                const Text('예약이 접수되었을 수 있습니다. 아래 예약 확정을 다시 눌러 결과를 확인해 주세요.'),
              if (!uncertain && !submitting)
                TextButton(
                    onPressed: config == null ? _initialize : _loadSlots,
                    child: const Text('다시 불러오기')),
            ])),
      Expanded(
          child: config == null
              ? const Center(child: Text('예약 정보를 불러오고 있습니다.'))
              : AbsorbPointer(
                  absorbing: loading || submitting || uncertain,
                  child: switch (step) {
                    0 => DateTimeStep(
                        dates: config!.dates,
                        slots: slots,
                        draft: draft,
                        onChanged: () {
                          if (draft.time == null) {
                            _loadSlots();
                          } else {
                            setState(() {});
                          }
                        }),
                    1 => PartyStep(
                        draft: draft,
                        onChanged: () {
                          _loadSlots();
                        }),
                    2 => ContactStep(
                        draft: draft, onChanged: () => setState(() {})),
                    _ => ConfirmStep(draft: draft, dates: config!.dates),
                  })),
      BookingBottomBar(
          step: step, enabled: canContinue, onBack: _back, onNext: _next),
    ]);
  }
}

class LookupScreen extends StatefulWidget {
  const LookupScreen({required this.onExit, required this.api, super.key});
  final VoidCallback onExit;
  final BookingRepository api;
  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  String phone = '';
  bool busy = false;
  String? message;
  List<Reservation> results = [];
  void _press(String value) {
    if (busy) return;
    setState(() {
      message = null;
      results = [];
      var input = phone;
      if (value == 'back') {
        if (input.isNotEmpty) input = input.substring(0, input.length - 1);
      } else if (input.length < 11) {
        input += value;
      }
      phone = input;
    });
  }

  Future<void> _search() async {
    setState(() {
      busy = true;
      message = null;
      results = [];
    });
    try {
      final value = await widget.api.lookup(phone);
      if (mounted) {
        setState(() {
          results = value;
          if (value.isEmpty) message = '일치하는 예약이 없습니다. 휴대폰 번호를 확인해 주세요.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => message = errorText(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        KioskHeader(onHome: widget.onExit),
        if (busy) const LinearProgressIndicator(),
        Expanded(
            child: ListView(padding: const EdgeInsets.all(28), children: [
          Text('예약을 확인할게요', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('예약할 때 입력한 휴대폰 번호를 입력해 주세요.'),
          const SizedBox(height: 16),
          PhoneDisplay(phone: phone),
          const SizedBox(height: 16),
          NumberPad(onPressed: _press),
          if (message != null)
            Padding(padding: const EdgeInsets.all(16), child: Text(message!)),
          if (results.isNotEmpty) const Text('최근 예약부터 최대 50건을 표시합니다.'),
          for (final row in results)
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('예약 번호 ${row.code}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('${row.dateLabel} · ${row.statusLabel}'),
                          Text(
                              '${row.players}명 · ${row.duration}분 · ${row.bayNumber}번 타석'),
                          Text('현장 결제 ${row.totalPrice}원'),
                        ]))),
        ])),
        Padding(
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              OutlinedButton(onPressed: widget.onExit, child: const Text('취소')),
              const SizedBox(width: 14),
              Expanded(
                  child: FilledButton(
                      onPressed: !busy && RegExp(r'^010\d{8}$').hasMatch(phone)
                          ? _search
                          : null,
                      child: const Text('예약 찾기'))),
            ])),
      ]);
}

class PairingScreen extends StatefulWidget {
  const PairingScreen({required this.api, required this.onPaired, super.key});
  final BookingRepository api;
  final VoidCallback onPaired;
  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  String code = '';
  String? message;
  bool busy = false;
  Future<void> _pair() async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await widget.api.pair(code);
      if (mounted) widget.onPaired();
    } catch (e) {
      if (mounted) setState(() => message = errorText(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        const KioskHeader(showHome: false),
        Expanded(
            child: ListView(padding: const EdgeInsets.all(28), children: [
          Text('키오스크 연결', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          const Text('직원용 CMS의 예약 관리에서 발급한 연결 코드 10자리를 입력해 주세요.'),
          const SizedBox(height: 24),
          Text(code.isEmpty ? '연결 코드 10자리' : code,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 24),
          NumberPad(onPressed: (value) {
            if (busy) return;
            setState(() {
              if (value == 'back') {
                if (code.isNotEmpty) code = code.substring(0, code.length - 1);
              } else if (code.length < 10) {
                code += value;
              }
            });
          }),
          if (message != null)
            Padding(padding: const EdgeInsets.all(16), child: Text(message!)),
          const SizedBox(height: 24),
          FilledButton(
              onPressed: !busy && code.length == 10 ? _pair : null,
              child: Text(busy ? '연결 중…' : '연결하기')),
        ])),
      ]);
}
