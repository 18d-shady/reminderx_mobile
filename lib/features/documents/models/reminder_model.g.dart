// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReminderCollection on Isar {
  IsarCollection<Reminder> get reminders => this.collection();
}

const ReminderSchema = CollectionSchema(
  name: r'Reminder',
  id: -8566764253612256045,
  properties: {
    r'recurrence': PropertySchema(
      id: 0,
      name: r'recurrence',
      type: IsarType.string,
    ),
    r'reminderMessage': PropertySchema(
      id: 1,
      name: r'reminderMessage',
      type: IsarType.string,
    ),
    r'reminderMethods': PropertySchema(
      id: 2,
      name: r'reminderMethods',
      type: IsarType.stringList,
    ),
    r'scheduledDate': PropertySchema(
      id: 3,
      name: r'scheduledDate',
      type: IsarType.dateTime,
    ),
    r'sent': PropertySchema(
      id: 4,
      name: r'sent',
      type: IsarType.bool,
    ),
    r'sentAt': PropertySchema(
      id: 5,
      name: r'sentAt',
      type: IsarType.dateTime,
    ),
    r'startDaysBefore': PropertySchema(
      id: 6,
      name: r'startDaysBefore',
      type: IsarType.long,
    )
  },
  estimateSize: _reminderEstimateSize,
  serialize: _reminderSerialize,
  deserialize: _reminderDeserialize,
  deserializeProp: _reminderDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'particular': LinkSchema(
      id: 338412408762749104,
      name: r'particular',
      target: r'Particular',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _reminderGetId,
  getLinks: _reminderGetLinks,
  attach: _reminderAttach,
  version: '3.1.8',
);

int _reminderEstimateSize(
  Reminder object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.recurrence.length * 3;
  {
    final value = object.reminderMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.reminderMethods.length * 3;
  {
    for (var i = 0; i < object.reminderMethods.length; i++) {
      final value = object.reminderMethods[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _reminderSerialize(
  Reminder object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.recurrence);
  writer.writeString(offsets[1], object.reminderMessage);
  writer.writeStringList(offsets[2], object.reminderMethods);
  writer.writeDateTime(offsets[3], object.scheduledDate);
  writer.writeBool(offsets[4], object.sent);
  writer.writeDateTime(offsets[5], object.sentAt);
  writer.writeLong(offsets[6], object.startDaysBefore);
}

Reminder _reminderDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Reminder();
  object.id = id;
  object.recurrence = reader.readString(offsets[0]);
  object.reminderMessage = reader.readStringOrNull(offsets[1]);
  object.reminderMethods = reader.readStringList(offsets[2]) ?? [];
  object.scheduledDate = reader.readDateTime(offsets[3]);
  object.sent = reader.readBool(offsets[4]);
  object.sentAt = reader.readDateTimeOrNull(offsets[5]);
  object.startDaysBefore = reader.readLong(offsets[6]);
  return object;
}

P _reminderDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reminderGetId(Reminder object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reminderGetLinks(Reminder object) {
  return [object.particular];
}

void _reminderAttach(IsarCollection<dynamic> col, Id id, Reminder object) {
  object.id = id;
  object.particular
      .attach(col, col.isar.collection<Particular>(), r'particular', id);
}

extension ReminderQueryWhereSort on QueryBuilder<Reminder, Reminder, QWhere> {
  QueryBuilder<Reminder, Reminder, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReminderQueryWhere on QueryBuilder<Reminder, Reminder, QWhereClause> {
  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReminderQueryFilter
    on QueryBuilder<Reminder, Reminder, QFilterCondition> {
  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> recurrenceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> recurrenceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recurrence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> recurrenceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recurrence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> recurrenceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recurrence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> recurrenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recurrence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> recurrenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recurrence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> recurrenceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recurrence',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> recurrenceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recurrence',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> recurrenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrence',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      recurrenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recurrence',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reminderMessage',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reminderMessage',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reminderMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reminderMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reminderMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reminderMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reminderMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderMethods',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reminderMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reminderMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reminderMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reminderMethods',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMethods',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reminderMethods',
        value: '',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderMethods',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderMethods',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderMethods',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderMethods',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderMethods',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      reminderMethodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'reminderMethods',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> scheduledDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      scheduledDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> scheduledDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> scheduledDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> sentEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sent',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> sentAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sentAt',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> sentAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sentAt',
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> sentAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sentAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> sentAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sentAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> sentAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sentAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> sentAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sentAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      startDaysBeforeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDaysBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      startDaysBeforeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDaysBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      startDaysBeforeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDaysBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition>
      startDaysBeforeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDaysBefore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReminderQueryObject
    on QueryBuilder<Reminder, Reminder, QFilterCondition> {}

extension ReminderQueryLinks
    on QueryBuilder<Reminder, Reminder, QFilterCondition> {
  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> particular(
      FilterQuery<Particular> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'particular');
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterFilterCondition> particularIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'particular', 0, true, 0, true);
    });
  }
}

extension ReminderQuerySortBy on QueryBuilder<Reminder, Reminder, QSortBy> {
  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByRecurrence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByRecurrenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByReminderMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMessage', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByReminderMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMessage', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortBySent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sent', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortBySentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sent', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortBySentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortBySentAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByStartDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> sortByStartDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDaysBefore', Sort.desc);
    });
  }
}

extension ReminderQuerySortThenBy
    on QueryBuilder<Reminder, Reminder, QSortThenBy> {
  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByRecurrence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByRecurrenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByReminderMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMessage', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByReminderMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMessage', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenBySent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sent', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenBySentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sent', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenBySentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenBySentAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.desc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByStartDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<Reminder, Reminder, QAfterSortBy> thenByStartDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDaysBefore', Sort.desc);
    });
  }
}

extension ReminderQueryWhereDistinct
    on QueryBuilder<Reminder, Reminder, QDistinct> {
  QueryBuilder<Reminder, Reminder, QDistinct> distinctByRecurrence(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrence', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByReminderMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderMessage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByReminderMethods() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderMethods');
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledDate');
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctBySent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sent');
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctBySentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sentAt');
    });
  }

  QueryBuilder<Reminder, Reminder, QDistinct> distinctByStartDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDaysBefore');
    });
  }
}

extension ReminderQueryProperty
    on QueryBuilder<Reminder, Reminder, QQueryProperty> {
  QueryBuilder<Reminder, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Reminder, String, QQueryOperations> recurrenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrence');
    });
  }

  QueryBuilder<Reminder, String?, QQueryOperations> reminderMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderMessage');
    });
  }

  QueryBuilder<Reminder, List<String>, QQueryOperations>
      reminderMethodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderMethods');
    });
  }

  QueryBuilder<Reminder, DateTime, QQueryOperations> scheduledDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledDate');
    });
  }

  QueryBuilder<Reminder, bool, QQueryOperations> sentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sent');
    });
  }

  QueryBuilder<Reminder, DateTime?, QQueryOperations> sentAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sentAt');
    });
  }

  QueryBuilder<Reminder, int, QQueryOperations> startDaysBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDaysBefore');
    });
  }
}
