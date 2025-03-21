import 'package:easyph/state.dart';
import 'package:easyph/ui/common/app_colors.dart';
import 'package:flutter/material.dart';


/// @author George David
/// email: georgequin19@gmail.com
/// Feb, 2024
///


class DropdownWidget extends StatelessWidget {
  final value;
  final List<String> itemsList;
  final List<String>? assets;
  final String hint;
  final Function onChanged;

  const DropdownWidget({
    Key? key,
    required this.value,
    required this.itemsList,
    required this.hint,
    required this.onChanged,
    this.assets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      itemHeight: 52.0,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(12),
        filled: true,
        fillColor:
            uiMode.value == AppUiModes.light ? kcWhiteColor : kcBlackColor,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kcBlackColor.withOpacity(0.22)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kcBlackColor.withOpacity(0.22)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kcBlackColor.withOpacity(0.22)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kcBlackColor.withOpacity(0.22)),
        ),
      ),
      iconSize: 30,
      iconEnabledColor:
          uiMode.value == AppUiModes.light ? kcBlackColor : kcWhiteColor,
      iconDisabledColor:
          uiMode.value == AppUiModes.light ? kcBlackColor : kcWhiteColor,
      hint: Text(
        value ?? hint,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: uiMode.value == AppUiModes.light ? kcBlackColor : kcWhiteColor,
        ),
      ),
      value: value,
      items: itemsList.map((String value) {
        int index = itemsList.indexOf(value);

        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              assets != null
                  ? Image.asset(
                      assets![index],
                      height: 20,
                      width: 20,
                    )
                  : const SizedBox(),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: uiMode.value == AppUiModes.light
                        ? kcBlackColor
                        : kcWhiteColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => onChanged(value),
    );
  }
}
