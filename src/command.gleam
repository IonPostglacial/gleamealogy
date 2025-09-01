import model

pub type Subject {
  SubjectPerson
  SubjectOccupation
  SubjectRelationship
  SubjectSource
  SubjectTree
  SubjectFile
  SubjectApplication
}

pub type Verb {
  VerbList
  VerbView
  VerbAdd
  VerbEdit
  VerbDelete
  VerbGenerateTree
  VerbImport
  VerbExport
  VerbHelp
  VerbQuit
}

pub type ProtoCommand {
  ProtoCommand(subject: Subject, verb: Verb)
}

pub fn possible_verbs(subject: Subject) -> List(Verb) {
  case subject {
    SubjectPerson | SubjectOccupation | SubjectRelationship | SubjectSource -> [
      VerbList,
      VerbView,
      VerbAdd,
      VerbEdit,
      VerbDelete,
    ]
    SubjectTree -> [VerbGenerateTree]
    SubjectFile -> [VerbImport, VerbExport]
    SubjectApplication -> [VerbHelp, VerbQuit]
  }
}

pub fn possible_subjects(verb: Verb) -> List(Subject) {
  case verb {
    VerbList | VerbView | VerbAdd | VerbEdit | VerbDelete -> [
      SubjectPerson,
      SubjectOccupation,
      SubjectRelationship,
      SubjectSource,
    ]
    VerbGenerateTree -> [SubjectTree]
    VerbImport | VerbExport -> [SubjectFile]
    VerbHelp | VerbQuit -> [SubjectApplication]
  }
}

pub type EntityCommand(t) {
  List
  View(Int)
  Add(t)
  Edit(Int, t)
  Delete(Int)
}

pub type TreeDirection {
  AscendingTree
  DescendingTree
  CompleteTree
}

pub type TreeCommand {
  GenerateTree(Int, TreeDirection)
}

pub type FileCommand {
  Export(String)
  Import(String)
}

pub type ApplicationCommand {
  Help
  Quit
}

pub type Command {
  Person(EntityCommand(model.Person))
  Occupation(EntityCommand(model.Occupation))
  Relationship(EntityCommand(model.Relationship))
  Source(EntityCommand(model.Source))
  Tree(TreeCommand)
  File(FileCommand)
  Application(ApplicationCommand)
}
