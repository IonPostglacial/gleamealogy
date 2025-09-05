import command.{type ProtoCommand, ProtoCommand}
import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import input.{input}

pub fn prompt_command() -> Result(ProtoCommand, String) {
  let in = input("Enter your command:\n\n" <> help_text())
  case in {
    Error(_) -> Error("could not get input")
    Ok(text) -> {
      let cmd = text_to_protocommand(text)
      case cmd {
        Ok(r) -> Ok(r)
        Error(s) -> {
          io.print(s)
          prompt_command()
        }
      }
    }
  }
}

fn help_text() -> String {
  "Commands have the following form:\n"
  <> " <subject><verb> where <subject> and <verb> are single letters\n"
  <> "subjects: [p]eople, [o]ccupations, [r]elations, [s]ources\n"
  <> "have the following verbs available:\n"
  <> "[l]ist, [v]iew, [a]dd, [e]dit, [d]elete\n"
  <> "subject [t]ree has [g]enerate\n"
  <> "subject [f]ile has [i]mport and e[x]port\n"
  <> "subject [a]pplication has [h]elp and [q]uit\n"
}

type InvalidSubject {
  InvalidSubject(subject: String)
}

type InvalidVerb {
  InvalidVerb(verb: String)
}

fn invalid_subject_to_string(s: String) -> String {
  "subject '" <> s <> "' does not exist"
}

fn invalid_verb_to_string(v: String) -> String {
  "verb '" <> v <> "' does not exist"
}

fn subject_help(subject: command.Subject) -> String {
  case subject {
    command.SubjectPerson -> "'p': Person"
    command.SubjectOccupation -> "'o': Occupation"
    command.SubjectRelationship -> "'r': Relationship"
    command.SubjectSource -> "'s': Source"
    command.SubjectTree -> "'t': Tree"
    command.SubjectFile -> "'f': File"
    command.SubjectApplication -> "'a': Application"
  }
}

fn verb_help(verb: command.Verb) -> String {
  case verb {
    command.VerbList -> "'l': List"
    command.VerbView -> "'e': Edit"
    command.VerbAdd -> "'a': Add"
    command.VerbEdit -> "'e': Edit"
    command.VerbDelete -> "'d': Delete"
    command.VerbGenerateTree -> "'g': Generate"
    command.VerbImport -> "'i': Import"
    command.VerbExport -> "'x': eXport"
    command.VerbHelp -> "'h': Helo"
    command.VerbQuit -> "'q': Quit"
  }
}

fn verb_suggestions(subject: command.Subject) -> String {
  command.possible_verbs(subject)
  |> list.map(fn(v) { "- " <> verb_help(v) })
  |> string.join("\n")
}

fn subject_suggestions(verb: command.Verb) -> String {
  command.possible_subjects(verb)
  |> list.map(fn(s) { "- " <> subject_help(s) })
  |> string.join("\n")
}

fn text_to_protocommand(text: String) -> Result(ProtoCommand, String) {
  case text |> string.trim() |> string.split("") {
    [subject, verb] -> {
      case text_to_subject(subject), text_to_verb(verb) {
        Ok(s), Ok(v) -> Ok(ProtoCommand(s, v))
        Ok(s), Error(InvalidVerb(v)) ->
          Error(
            invalid_verb_to_string(v)
            <> "\nvalid verbs for subject '"
            <> subject
            <> "' are:\n"
            <> verb_suggestions(s),
          )
        Error(InvalidSubject(s)), Ok(v) ->
          Error(
            invalid_subject_to_string(s)
            <> "\nvalid subjects for verb '"
            <> verb
            <> "' are:\n"
            <> subject_suggestions(v),
          )
        Error(InvalidSubject(s)), Error(InvalidVerb(v)) ->
          Error(
            invalid_verb_to_string(v) <> "\n" <> invalid_subject_to_string(s),
          )
      }
    }
    _ -> Error("invalid command\n\n" <> help_text())
  }
}

fn text_to_subject(subject: String) -> Result(command.Subject, InvalidSubject) {
  case subject {
    "p" -> Ok(command.SubjectPerson)
    "o" -> Ok(command.SubjectOccupation)
    "r" -> Ok(command.SubjectRelationship)
    "s" -> Ok(command.SubjectSource)
    "t" -> Ok(command.SubjectTree)
    "f" -> Ok(command.SubjectFile)
    "a" -> Ok(command.SubjectApplication)
    _ -> Error(InvalidSubject(subject))
  }
}

fn text_to_verb(verb: String) -> Result(command.Verb, InvalidVerb) {
  case verb {
    "l" -> Ok(command.VerbList)
    "v" -> Ok(command.VerbView)
    "a" -> Ok(command.VerbAdd)
    "e" -> Ok(command.VerbEdit)
    "d" -> Ok(command.VerbDelete)
    "g" -> Ok(command.VerbGenerateTree)
    "i" -> Ok(command.VerbImport)
    "x" -> Ok(command.VerbExport)
    "h" -> Ok(command.VerbHelp)
    "q" -> Ok(command.VerbQuit)
    _ -> Error(InvalidVerb(verb))
  }
}

type FieldKind {
  TextField(max_size: Int)
  DateField
  IntegerField(min: Int, max: Int)
}

type FormField {
  FormField(label: String, optional: Bool, kind: FieldKind)
}

type FormValue {
  TextValue
  DateValue
  IntegerValue
}

fn parse_form_value(field: FormField, raw_value: String) -> Option(FormValue) {
  case field.kind {
    DateField -> todo
    IntegerField(min:, max:) -> todo
    TextField(max_size:) -> todo
  }
}

fn prompt_field(field: FormField, t: fn(String) -> String) -> Option(FormValue) {
  let field_label = t(field.label)
  let raw_value = input(field_label <> ":")
  case raw_value {
    Error(_) -> None
    Ok(v) -> parse_form_value(field, v)
  }
}

type FieldSet {
  FieldSet(label: Option(String), fields: List(FormField))
}

fn prompt_fieldset(
  fs: FieldSet,
  t: fn(String) -> String,
) -> List(#(String, FormValue)) {
  case fs.label {
    None -> Nil
    Some(label) -> io.print(t(label) <> "\n")
  }
  fs.fields
  |> list.flat_map(fn(field) {
    let value = prompt_field(field, t)
    case value {
      None -> []
      Some(v) -> [#(field.label, v)]
    }
  })
}

type Form {
  Form(label: String, fieldsets: List(FieldSet))
}

fn prompt_form(
  form: Form,
  t: fn(String) -> String,
) -> dict.Dict(String, FormValue) {
  io.print(t(form.label) <> "\n")
  list.map(form.fieldsets, prompt_fieldset(_, t))
  |> list.flatten()
  |> dict.from_list()
}
