JsOsaDAS1.001.00bplist00�Vscript_function TaskPaperContextScript(editor, options) {
  var outline = editor.outline;
  // group all the changes together into a single change and make it a single "undo" action
  outline.groupUndoAndChanges(function () {
    // all the projects
    var projects_array = outline.evaluateItemPath('@type=project except archive:');
    // for each project as "pjc", get all the children (any @types)
    projects_array.forEach(function(pjc) {
      var has_children = pjc.hasChildren;
      if(!has_children) {
        return;
      }
      var children = pjc.children; 

      // handle the case of only one item in a project
      if(children.length < 2) {
        return;
      }

      // Sort all @done tags in ascending order based on tag date value
      // at the bottom of the list.
      children.sort(function (a, b) {
        // get the date value of all items tagged @done(date),
        // "getAttribute" takes the attribute date,
        // and whether or not the value should be converted to something else
        // (in this case a Date).
        var a_doneDate = a.getAttribute('data-done', Date);
        var b_doneDate = b.getAttribute('data-done', Date);

        // Here null means the item didn't have a @due tag with a date value
        if(a_doneDate == null && b_doneDate != null) {
          return -1 ;
        }
        else if (a_doneDate != null && b_doneDate == null) {
          return 1;
        }
        else if (a_doneDate == null && b_doneDate == null) {
          return 0;
        }
        else {
          return a_doneDate - b_doneDate;
        }
      }); // end sort 

      // Push all sub-items with a @status tag at the bottom of the project list
      for (var i = children.length - 1; i >= 0; i--) {
        if (children[i].hasAttribute('data-status')){
          children.push(children.splice(children.indexOf(children[i]), 1)[0]); 
        }
      }

      // Sort all sub-items (at the bottom of the list) with a @status tag 
      // in ascending order based on @done tag date value.
      children.sort(function (a, b) {
        // get the sub-projects items tagged with a @status
        var a_hasStatus = a.hasAttribute('data-status');
        var b_hasStatus = b.hasAttribute('data-status');

        // get the date value of all items tagged @done(date),
        // "getAttribute" takes the attribute date,
        // and whether or not the value should be converted to something else
        // (in this case a Date)
        var a_doneDate = a.getAttribute('data-done', Date);
        var b_doneDate = b.getAttribute('data-done', Date);

        // Sort only the sub-projects at the bottom of the list with
        // a @status tag and by @done date
        if (a_hasStatus == true && b_hasStatus == true) {
          // Here null means the item didn't have a @due tag with a date value
          if(a_doneDate == null && b_doneDate != null) {
            return -1 ;
          }
          else if (a_doneDate != null && b_doneDate == null) {
            return 1;
          }
          else if (a_doneDate == null && b_doneDate == null) {
            return 0;
          }
          else {
            return a_doneDate - b_doneDate;
          }
        }
        else
        {
          return 0;
        }
      }); // end sort 

      pjc.removeChildren(pjc.children);
      pjc.appendChildren(children);
    }); // end projects_array.forEach 
  }); // end outline.groupUndoAndChanges
} // end TaskPaperContextScript

var string = Application("TaskPaper").documents[0].evaluate({
  script: TaskPaperContextScript.toString()
});                              jscr  ��ޭ