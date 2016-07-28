
function initial_checkAllElements() {
    var timeline_data = _TL_DATA; // Copy original timeline elements as reference
    var new_timeline_data = jQuery.extend(true, {}, _TL_DATA); // Clone the object, do not reference it
    var new_object = {};
    new_object.name = "Elements";
    new_object.color = "#000000";
    if (!this.checked) {
        if (new_timeline_data.spans != null &&
            new_timeline_data.spans.length > 0) {
            new_timeline_data.spans = $.grep(_TL_DATA.spans,
                function (item, index) {
                    return item.id == "";
                });
        }
    } else {
        var objects = [];
        $("#tblLeftGridElements input:checked:visible").each(
            function () {
                var ids = $(this).attr("value");
                if (ids != null) {
                    var id_array = ids.split("#");
                    if (id_array.length > 1) {
                        objects.push(id_array[0]);
                    }
                }
            })
        var element_checks = [];

        // Loop into types
        for (obj in objects) {
            if (elementsInMemory != null && elementsInMemory.length > 0) {
                for (var i = 0; i < elementsInMemory.length; i++) {
                    var element = elementsInMemory[i];
                    if (element != null) {
                        var tapeID = element.tapeID;

                        if (objects[obj] == tapeID) {
                            var groupName = element.groupName;
                            var tapeType = element.tapeType;
                            var duration = element.duration;
                            var timestamp = element.timestamp;
                            var segmentID = element.segmentID;
                            var count = element.count;
                            var fileName = element.fileName;
                            var endDate = element.endDate;
                            var filePath = element.filePath;
                            var duration_formatStr = element.duration_formatStr;
                            var fileStatus = element.fileStatus;

                            var tapeType_str = tapeType;
                            if (tapeType == "S") {
                                tapeType_str = "P";
                            }

                            // Create object
                            var object_group = {};
                            object_group.name = tapeType_str; //
                            object_group.start = timestamp;
                            object_group.end = endDate;
                            object_group.id = tapeID;
                            object_group.role = groupName;
                            object_group.type = tapeType;
                            element_checks.push(object_group);
                        }
                    }
                } //for
            }
        } //for

        // Append role elements to original elements
        var allTags = [];
        allTags.push.apply(allTags, _TL_DATA.spans);
        allTags.push.apply(allTags, element_checks);
        new_object.spans = allTags;
        new_timeline_data = new_object;
    }
    _TL_DATA = new_timeline_data;
    prepareTimelineReload(new_timeline_data);
}