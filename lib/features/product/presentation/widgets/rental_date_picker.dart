import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';

typedef DateRangeCallback = void Function(DateTimeRange range);

/// Muestra un modal con un selector de rango de fechas (inicio - fin).
/// Devuelve un `DateTimeRange` cuando el usuario confirma, o `null` si cancela.
Future<DateTimeRange?> showRentalDateRangePicker(
	BuildContext context, {
	DateTime? initialStart,
	DateTime? initialEnd,
}) {
	return showModalBottomSheet<DateTimeRange?>(
		context: context,
		isScrollControlled: true,
		backgroundColor: Colors.transparent,
		builder: (ctx) => RentalDatePickerDialog(
			parentContext: ctx,
			initialStart: initialStart,
			initialEnd: initialEnd,
		),
	);
}

class RentalDatePickerDialog extends StatefulWidget {
	final DateTime? initialStart;
	final DateTime? initialEnd;
	final BuildContext? parentContext;

	const RentalDatePickerDialog({
		Key? key,
		this.parentContext,
		this.initialStart,
		this.initialEnd,
	}) : super(key: key);

	@override
	State<RentalDatePickerDialog> createState() => _RentalDatePickerDialogState();
}

class _RentalDatePickerDialogState extends State<RentalDatePickerDialog> {
	DateTime? start;
	DateTime? end;
	late DateTime firstMonth; // first month to display

	final List<String> monthNames = const [
		'Enero',
		'Febrero',
		'Marzo',
		'Abril',
		'Mayo',
		'Junio',
		'Julio',
		'Agosto',
		'Septiembre',
		'Octubre',
		'Noviembre',
		'Diciembre',
	];

	final List<String> weekdayShort = const [
		'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'
	];

	@override
	void initState() {
		super.initState();
		start = widget.initialStart;
		end = widget.initialEnd;
		final now = DateTime.now();
		firstMonth = DateTime(now.year, now.month);
	}

	void _onDateTap(DateTime date) {
		final today = DateTime.now();
		final d = DateTime(date.year, date.month, date.day);
		if (d.isBefore(DateTime(today.year, today.month, today.day))) return;

		setState(() {
			if (start == null || (start != null && end != null)) {
				start = d;
				end = null;
			} else if (start != null && end == null) {
				if (d.isBefore(start!)) {
					start = d;
				} else if (d.isAtSameMomentAs(start!)) {
					// keep single-day selection as both start and end
					end = start;
				} else {
					end = d;
				}
			}
		});
	}

	bool _isInRange(DateTime day) {
		if (start == null) return false;
		if (end == null) return day.isAtSameMomentAs(start!);
		return (day.isAtSameMomentAs(start!) || day.isAtSameMomentAs(end!)) ||
				(day.isAfter(start!) && day.isBefore(end!));
	}

	bool _isStart(DateTime day) => start != null && day.isAtSameMomentAs(start!);
	bool _isEnd(DateTime day) => end != null && day.isAtSameMomentAs(end!);

	Widget _buildMonth(DateTime month) {
		final year = month.year;
		final monthIndex = month.month;
		final firstOfMonth = DateTime(year, monthIndex, 1);
		final daysInMonth = DateTime(year, monthIndex + 1, 0).day;

		final weekDayOfFirst = firstOfMonth.weekday; // 1 = Mon
		final leadingEmpty = (weekDayOfFirst - 1) % 7; // number of blanks before first

		final today = DateTime.now();

		List<Widget> dayWidgets = [];

		// weekday headers
		for (final w in weekdayShort) {
			dayWidgets.add(Center(
				child: Text(
					w,
					style: const TextStyle(fontSize: 12, color: Colors.grey),
				),
			));
		}

		// leading blanks
		for (int i = 0; i < leadingEmpty; i++) {
			dayWidgets.add(const SizedBox.shrink());
		}

		// days
		for (int day = 1; day <= daysInMonth; day++) {
			final dt = DateTime(year, monthIndex, day);
			final isDisabled = dt.isBefore(DateTime(today.year, today.month, today.day));

			final inRange = _isInRange(dt);
			final isStart = _isStart(dt);
			final isEnd = _isEnd(dt);

			BoxDecoration? deco;
			TextStyle textStyle = TextStyle(color: isDisabled ? Colors.grey.shade400 : Colors.black);

			if (inRange) {
				if (isStart || isEnd) {
					deco = BoxDecoration(
						color: AppColors.primary,
						shape: BoxShape.rectangle,
					);
					textStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
				} else {
					deco = BoxDecoration(
						color: Colors.deepPurple[200],
						borderRadius: BorderRadius.circular(4),
					);
				}
			}

			final child = GestureDetector(
				onTap: isDisabled ? null : () => _onDateTap(dt),
				child: Container(
					margin: const EdgeInsets.all(6),
					decoration: deco,
					alignment: Alignment.center,
					child: Text('$day', style: textStyle),
				),
			);

			dayWidgets.add(child);
		}

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Padding(
					padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
					child: Text(
						'${monthNames[monthIndex - 1]} ${year}',
						style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
					),
				),
				GridView.count(
					crossAxisCount: 7,
					shrinkWrap: true,
					physics: const NeverScrollableScrollPhysics(),
					childAspectRatio: 1.1,
					padding: const EdgeInsets.symmetric(horizontal: 8),
					children: dayWidgets,
				),
			],
		);
	}

	@override
	Widget build(BuildContext context) {

		return DraggableScrollableSheet(
			initialChildSize: 0.75,
			minChildSize: 0.4,
			maxChildSize: 0.95,
			builder: (context, scrollController) {
								return Stack(
									clipBehavior: Clip.none,
									children: [
										Container(
											decoration: BoxDecoration(
												color: Colors.white,
												borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
											),
											child: Column(
												mainAxisSize: MainAxisSize.min,
												children: [
													// small handle
													Padding(
														padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
														child: Container(
															width: 56,
															height: 4,
															decoration: BoxDecoration(
																color: Colors.grey[300],
																borderRadius: BorderRadius.circular(2),
															),
														),
													),

													// title centered
													Padding(
														padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
														child: Center(
															child: Text('Seleccionar fecha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
														),
													),

													// start/end summary
													Padding(
														padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
														child: Container(
															margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
															padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
															decoration: BoxDecoration(
																color: Colors.grey[100],
																borderRadius: BorderRadius.circular(12),
															),
															child: Row(
																mainAxisAlignment: MainAxisAlignment.spaceBetween,
																children: [
																	Column(
																		crossAxisAlignment: CrossAxisAlignment.start,
																		children: [
																			const Text('Inicio', style: TextStyle(fontSize: 12, color: Colors.grey)),
																			const SizedBox(height: 4),
																			Text(start != null ? '${start!.day}/${start!.month}/${start!.year}' : '--', style: const TextStyle(fontWeight: FontWeight.w600)),
																		],
																	),
																	Column(
																		crossAxisAlignment: CrossAxisAlignment.end,
																		children: [
																			const Text('Fin', style: TextStyle(fontSize: 12, color: Colors.grey)),
																			const SizedBox(height: 4),
																			Text(end != null ? '${end!.day}/${end!.month}/${end!.year}' : '--', style: const TextStyle(fontWeight: FontWeight.w600)),
																		],
																	),
																],
															),
														),
													),

													// scrollable months
													Expanded(
														child: SingleChildScrollView(
															controller: scrollController,
															child: Padding(
																padding: const EdgeInsets.symmetric(horizontal: 8.0),
																child: Column(
																	children: [
																		_buildMonth(firstMonth),
																		const SizedBox(height: 8),
																		_buildMonth(DateTime(firstMonth.year, firstMonth.month + 1)),
																		const SizedBox(height: 16),
																	],
																),
															),
														),
													),

													SafeArea(
														top: false,
														child: Padding(
															padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
															child: ElevatedButton(
																style: ElevatedButton.styleFrom(
																	minimumSize: const Size.fromHeight(52),
																	shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
																	backgroundColor: start != null && end != null ? AppColors.primary : Colors.grey[400],
																),
																onPressed: start != null && end != null
																		? () {
																			final range = DateTimeRange(start: start!, end: end!);
																			final popCtx = widget.parentContext ?? context;
																			Navigator.of(popCtx).pop(range);
																		}
																		: null,
																child: const Text('Confirmar', style: TextStyle(fontSize: 16, color: Colors.white)),
															),
														),
													),
												],
											),
										),

                    Positioned(
                      right: 10,
                      top: 20,
                      child: Transform.translate(
                        offset: const Offset(0, -28),
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 6,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              final popCtx = widget.parentContext ?? context;
                              Navigator.of(popCtx).pop();
                            },
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(child: Icon(Icons.close, size: 18, color: AppColors.primary)),
                            ),
                          ),
                        ),
                      ),
                    ),
									],
								);
			},
		);
	}
}

