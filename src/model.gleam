import bimultimap
import gleam/dict
import gleam/option.{type Option}

pub type Gender {
  Male
  Female
  Neutral
  NonBinary
  Other(String)
}

pub type Month {
  January
  February
  March
  April
  May
  June
  July
  August
  September
  October
  November
  December
}

pub type ExactDate {
  ExactDate(year: Int, month: Month, day: Int)
}

pub type ApproximateDate {
  Before(ExactDate)
  After(ExactDate)
  Between(ExactDate, ExactDate)
  About(ExactDate)
}

pub type Date {
  Exact(ExactDate)
  Approximate(ApproximateDate)
}

pub type Page {
  SinglePage(Int)
  PageRange(Int, Int)
}

pub type Coordinates {
  Coordinates(latitude: Float, longitude: Float)
}

pub type Location {
  Location(
    country: String,
    city: String,
    coordinates: Option(Coordinates),
    address: String,
    postal_code: String,
    notes: String,
  )
}

pub type Name {
  Name(given: String, family: String, birth: Option(String))
}

pub type SourceKind {
  Book(publisher: String, isbn: String, page: Page)
  Article(journal: String, volume: Option(Int), issue: Option(Int), page: Page)
  Website(fragment: Option(String))
  Interview(interviewer: Name, interviewee: Name)
  LegalDocument(page: Page)
  OtherSource(notes: String)
}

pub type Source {
  Source(
    id: Int,
    title: String,
    main_author: Name,
    co_authors: List(Name),
    url: Option(String),
    location: Option(Location),
    created_at: Option(Date),
    retrieved_at: Option(Date),
    kind: SourceKind,
  )
}

pub type OccupationKind {
  Unemployed
  Employed(String)
  SelfEmployed(String)
  Retired
  Student(String)
  OtherOccupation(String)
}

pub type TimePeriod {
  TimePeriod(start: Date, end: Date)
  AfterDate(Date)
  BeforeDate(Date)
}

pub type Occupation {
  Occupation(
    id: Int,
    kind: OccupationKind,
    period: Option(TimePeriod),
    organization: Option(String),
    location: Option(Location),
    sources: List(Source),
    notes: String,
  )
}

pub type DivorceReason {
  Adultery
  Desertion
  Abuse
  IrreconcilableDifferences
  OtherDivorceReason(String)
}

pub type JudgementKind {
  DivorceJudgement(reason: Option(DivorceReason))
  ChildSupportJudgement
  AdoptionJudgement
  NameChangeJudgement
  OtherJudgement(String)
}

pub type EventKind {
  Judgement(JudgementKind)
  OtherEvent(String)
}

pub type Event {
  Event(
    id: Int,
    kind: EventKind,
    date: Date,
    location: Location,
    sources: List(Source),
    notes: String,
  )
}

pub type Person {
  Person(
    id: Int,
    name: Name,
    gender: Gender,
    birth: Option(Date),
    death: Option(Date),
    events: List(Event),
    occupations: List(Occupation),
    sources: List(Source),
    notes: String,
  )
}

pub type BiologicalParentRole {
  BiologicalFather
  BiologicalMother
}

pub type AdoptiveParentRole {
  AdoptiveFather
  AdoptiveMother
  AdoptiveOther(String)
}

pub type Parent {
  BiologicalParent(BiologicalParentRole)
  AdoptiveParent(AdoptiveParentRole)
}

pub type Sibling {
  FullSibling
  HalfSibling
  StepSibling
  AdoptiveSibling
  OtherSibling(String)
}

pub type Partnership {
  Husband
  Wife
  Boyfriend
  Girlfriend
  CivilPartner
  FriendWithBenefits
  OtherPartnership(String)
}

pub type RelationshipKind {
  ParentChild(Parent)
  SiblingRelationship(Sibling)
  PartnershipRelationship(Partnership)
  Tutor
  Owner
  Colleague
  Friend
  OtherRelationship(String)
}

pub type Relationship {
  Relationship(
    id: Int,
    person1: Person,
    person2: Person,
    kind: RelationshipKind,
    period: Option(TimePeriod),
    sources: List(Source),
    notes: String,
  )
}

pub opaque type Dataset {
  Dataset(
    id: Int,
    people_by_id: dict.Dict(Int, Person),
    relationships_by_id: dict.Dict(Int, Relationship),
    relationships_by_persons: bimultimap.BiMultiMap(Int, Relationship),
    created_at: Date,
    updated_at: Date,
    notes: String,
  )
}

pub fn new(id: Int, created_at: Date) -> Dataset {
  Dataset(
    id,
    people_by_id: dict.new(),
    relationships_by_id: dict.new(),
    relationships_by_persons: bimultimap.new(),
    created_at: created_at,
    updated_at: created_at,
    notes: "",
  )
}

pub fn id(dataset: Dataset) -> Int {
  dataset.id
}

pub fn created_at(dataset: Dataset) -> Date {
  dataset.created_at
}

pub fn updated_at(dataset: Dataset) -> Date {
  dataset.updated_at
}

pub fn people_ids(dataset: Dataset) -> List(Int) {
  dataset.people_by_id |> dict.keys()
}

pub fn person_by_id(dataset: Dataset, id: Int) -> Result(Person, Nil) {
  dataset.people_by_id |> dict.get(id)
}

pub fn insert_person(dataset: Dataset, person: Person) -> Dataset {
  Dataset(
    ..dataset,
    people_by_id: dataset.people_by_id
      |> dict.insert(person.id, person),
  )
}

pub fn delete_person(dataset: Dataset, person: Person) -> Dataset {
  Dataset(
    ..dataset,
    people_by_id: dataset.people_by_id
      |> dict.delete(person.id),
  )
}

pub fn relationship_ids(dataset: Dataset) -> List(Int) {
  dataset.relationships_by_id |> dict.keys()
}

pub fn relationship_by_id(
  dataset: Dataset,
  id: Int,
) -> Result(Relationship, Nil) {
  dataset.relationships_by_id |> dict.get(id)
}

pub fn relationships_of_person1(dataset: Dataset, id: Int) -> List(Relationship) {
  dataset.relationships_by_persons
  |> bimultimap.get_forward(id)
}

pub fn relationships_of_person2(dataset: Dataset, id: Int) -> List(Relationship) {
  dataset.relationships_by_persons
  |> bimultimap.get_backward(id)
}

pub fn insert_relationship(
  dataset: Dataset,
  relationship: Relationship,
) -> Dataset {
  Dataset(
    ..dataset,
    relationships_by_id: dataset.relationships_by_id
      |> dict.insert(relationship.id, relationship),
    relationships_by_persons: dataset.relationships_by_persons
      |> bimultimap.insert(
        relationship.person1.id,
        relationship.person2.id,
        relationship,
      ),
  )
}

pub fn delete_relationship(
  dataset: Dataset,
  relationship: Relationship,
) -> Dataset {
  Dataset(
    ..dataset,
    relationships_by_id: dataset.relationships_by_id
      |> dict.delete(relationship.id),
    relationships_by_persons: dataset.relationships_by_persons
      |> bimultimap.delete(
        relationship.person1.id,
        relationship.person2.id,
        relationship,
      ),
  )
}
