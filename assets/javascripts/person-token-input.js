$(document).ready(function() {
  $('#person_skill_list').tokenInput('/people/skills', {
    crossDomain: false,
    theme: 'facebook',
    preventDuplicates: true,
    prePopulate: $("#person_skill_list").data("pre"),
    allowCreation: true,
    createTokenText: 'Add new skill',
  });

  $('#person_foreign_language_list').tokenInput('/people/foreign_languages', {
    crossDomain: false,
    theme: 'facebook',
    preventDuplicates: true,
    prePopulate: $("#person_foreign_language_list").data("pre"),
    allowCreation: true,
    createTokenText: 'Add new language'
  });

  $('#person_hobby_list').tokenInput('/people/hobbies', {
    crossDomain: false,
    theme: 'facebook',
    preventDuplicates: true,
    prePopulate: $("#person_hobby_list").data("pre"),
    allowCreation: true,
    createTokenText: 'Add new hobbie'
  });
})
