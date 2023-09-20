import 'package:feelingapp/main.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';

enum TAG_TYPE {
  ATTRIBUTE,
  INTEREST,
}

class Tag extends Taggable {
  final String name;
  final String id;
  final TAG_TYPE type;

  Tag({
    this.name,
    this.id,
    this.type,
  });

  @override
  List<Object> get props => [name];
}

/// TagService
class TagService {
  static List<Tag> getInterests(String query) {
    List<Map<String, dynamic>> tagNames = [];
    currentUser.tagInterests.keys.forEach((k) {
      tagNames.add({"id": k, "pop": currentUser.tagInterests[k]["pop"]});
    });

    tagNames.sort((v1, v2) {
      return v2["pop"] - v1["pop"];
    });

    List<Tag> tags = [];

    for (Map<String, dynamic> it in tagNames) {
      tags.add(Tag(
          name: currentUser.tagInterests[it['id']]['val'],
          id: it['id'],
          type: TAG_TYPE.ATTRIBUTE));
    }

    return tags
        .where((tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static List<Tag> getAttributes(String query, int tagGender) {
    List<Map<String, dynamic>> tagNames = [];

    String tagSelectionPrefix = "";
    
    if(tagGender == 0) {
      tagSelectionPrefix = "m_";
    }

    else if(tagGender == 1){
      tagSelectionPrefix = "f_";
    }

    currentUser.tagAttributes.keys.where((element) => element.startsWith(tagSelectionPrefix)).forEach((k) {
      tagNames.add({"id": k, "pop": currentUser.tagAttributes[k]["pop"]});
    });

    tagNames.sort((v1, v2) {
      return v2["pop"] - v1["pop"];
    });

    List<Tag> tags = [];

    for (Map<String, dynamic> it in tagNames) {
      tags.add(Tag(
          name: currentUser.tagAttributes[it['id']]['val'],
          id: it['id'],
          type: TAG_TYPE.ATTRIBUTE));
    }

    return tags
        .where((tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}




class TagChip extends StatefulWidget {
  final String title;
  final String id;
  final TAG_TYPE type;
  final onTapCallback;
  final bool enabled;
  final double fontSize;
  final bool addShadows;
  TagChip(
      {@required this.title,
      @required this.id,
      @required this.type,
      this.onTapCallback,
      this.enabled,
      this.fontSize = 21,
      this.addShadows = false});

  @override
  _TagChipState createState() => _TagChipState();
}

class _TagChipState extends State<TagChip> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            //enabled = !enabled;
            widget.onTapCallback(widget.title,widget.id, widget.type);
          });
        },
        child: Container(
            padding: EdgeInsets.only(top: 5, right: 5, left: 5),
            child: Container(
              decoration: BoxDecoration(
                color: widget.enabled
                    ? (widget.type == TAG_TYPE.ATTRIBUTE
                        ? Style().dazzlePrimaryColor
                        : Style().dazzleSecondaryColor)
                    : Colors.transparent,
                border: Border.all(
                    color: (widget.type == TAG_TYPE.ATTRIBUTE
                        ? Style().dazzlePrimaryColor
                        : Style().dazzleSecondaryColor),
                    width: 2),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child:Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  shadows: widget.addShadows  ? Style().textOutlineWithShadows : null,
                  fontSize: widget.fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ))));
  }
}
