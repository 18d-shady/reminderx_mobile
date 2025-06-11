// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppNotificationCollection on Isar {
  IsarCollection<AppNotification> get appNotifications => this.collection();
}

const AppNotificationSchema = CollectionSchema(
  name: r'AppNotification',
  id: 7576332975032865864,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isSent': PropertySchema(
      id: 1,
      name: r'isSent',
      type: IsarType.bool,
    ),
    r'message': PropertySchema(
      id: 2,
      name: r'message',
      type: IsarType.string,
    ),
    r'particularTitle': PropertySchema(
      id: 3,
      name: r'particularTitle',
      type: IsarType.string,
    ),
    r'sendEmail': PropertySchema(
      id: 4,
      name: r'sendEmail',
      type: IsarType.bool,
    ),
    r'sendPush': PropertySchema(
      id: 5,
      name: r'sendPush',
      type: IsarType.bool,
    ),
    r'sendSms': PropertySchema(
      id: 6,
      name: r'sendSms',
      type: IsarType.bool,
    ),
    r'sendWhatsapp': PropertySchema(
      id: 7,
      name: r'sendWhatsapp',
      type: IsarType.bool,
    ),
    r'sentAt': PropertySchema(
      id: 8,
      name: r'sentAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _appNotificationEstimateSize,
  serialize: _appNotificationSerialize,
  deserialize: _appNotificationDeserialize,
  deserializeProp: _appNotificationDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appNotificationGetId,
  getLinks: _appNotificationGetLinks,
  attach: _appNotificationAttach,
  version: '3.1.8',
);

int _appNotificationEstimateSize(
  AppNotification object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.message.length * 3;
  bytesCount += 3 + object.particularTitle.length * 3;
  return bytesCount;
}

void _appNotificationSerialize(
  AppNotification object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isSent);
  writer.writeString(offsets[2], object.message);
  writer.writeString(offsets[3], object.particularTitle);
  writer.writeBool(offsets[4], object.sendEmail);
  writer.writeBool(offsets[5], object.sendPush);
  writer.writeBool(offsets[6], object.sendSms);
  writer.writeBool(offsets[7], object.sendWhatsapp);
  writer.writeDateTime(offsets[8], object.sentAt);
}

AppNotification _appNotificationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppNotification();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.isSent = reader.readBool(offsets[1]);
  object.message = reader.readString(offsets[2]);
  object.particularTitle = reader.readString(offsets[3]);
  object.sendEmail = reader.readBool(offsets[4]);
  object.sendPush = reader.readBool(offsets[5]);
  object.sendSms = reader.readBool(offsets[6]);
  object.sendWhatsapp = reader.readBool(offsets[7]);
  object.sentAt = reader.readDateTimeOrNull(offsets[8]);
  return object;
}

P _appNotificationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appNotificationGetId(AppNotification object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appNotificationGetLinks(AppNotification object) {
  return [];
}

void _appNotificationAttach(
    IsarCollection<dynamic> col, Id id, AppNotification object) {
  object.id = id;
}

extension AppNotificationQueryWhereSort
    on QueryBuilder<AppNotification, AppNotification, QWhere> {
  QueryBuilder<AppNotification, AppNotification, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppNotificationQueryWhere
    on QueryBuilder<AppNotification, AppNotification, QWhereClause> {
  QueryBuilder<AppNotification, AppNotification, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<AppNotification, AppNotification, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterWhereClause> idBetween(
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

extension AppNotificationQueryFilter
    on QueryBuilder<AppNotification, AppNotification, QFilterCondition> {
  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      isSentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSent',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'message',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'message',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'message',
        value: '',
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'message',
        value: '',
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'particularTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'particularTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'particularTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'particularTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'particularTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'particularTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'particularTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'particularTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'particularTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      particularTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'particularTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sendEmailEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sendEmail',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sendPushEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sendPush',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sendSmsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sendSms',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sendWhatsappEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sendWhatsapp',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sentAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sentAt',
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sentAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sentAt',
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sentAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sentAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sentAtGreaterThan(
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

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sentAtLessThan(
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

  QueryBuilder<AppNotification, AppNotification, QAfterFilterCondition>
      sentAtBetween(
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
}

extension AppNotificationQueryObject
    on QueryBuilder<AppNotification, AppNotification, QFilterCondition> {}

extension AppNotificationQueryLinks
    on QueryBuilder<AppNotification, AppNotification, QFilterCondition> {}

extension AppNotificationQuerySortBy
    on QueryBuilder<AppNotification, AppNotification, QSortBy> {
  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> sortByIsSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSent', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortByIsSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSent', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> sortByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortByParticularTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'particularTitle', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortByParticularTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'particularTitle', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortBySendEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendEmail', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortBySendEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendEmail', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortBySendPush() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendPush', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortBySendPushDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendPush', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> sortBySendSms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendSms', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortBySendSmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendSms', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortBySendWhatsapp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendWhatsapp', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortBySendWhatsappDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendWhatsapp', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> sortBySentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      sortBySentAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.desc);
    });
  }
}

extension AppNotificationQuerySortThenBy
    on QueryBuilder<AppNotification, AppNotification, QSortThenBy> {
  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> thenByIsSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSent', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenByIsSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSent', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> thenByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenByParticularTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'particularTitle', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenByParticularTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'particularTitle', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenBySendEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendEmail', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenBySendEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendEmail', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenBySendPush() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendPush', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenBySendPushDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendPush', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> thenBySendSms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendSms', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenBySendSmsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendSms', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenBySendWhatsapp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendWhatsapp', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenBySendWhatsappDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sendWhatsapp', Sort.desc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy> thenBySentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.asc);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QAfterSortBy>
      thenBySentAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.desc);
    });
  }
}

extension AppNotificationQueryWhereDistinct
    on QueryBuilder<AppNotification, AppNotification, QDistinct> {
  QueryBuilder<AppNotification, AppNotification, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AppNotification, AppNotification, QDistinct> distinctByIsSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSent');
    });
  }

  QueryBuilder<AppNotification, AppNotification, QDistinct> distinctByMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'message', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QDistinct>
      distinctByParticularTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'particularTitle',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppNotification, AppNotification, QDistinct>
      distinctBySendEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sendEmail');
    });
  }

  QueryBuilder<AppNotification, AppNotification, QDistinct>
      distinctBySendPush() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sendPush');
    });
  }

  QueryBuilder<AppNotification, AppNotification, QDistinct>
      distinctBySendSms() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sendSms');
    });
  }

  QueryBuilder<AppNotification, AppNotification, QDistinct>
      distinctBySendWhatsapp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sendWhatsapp');
    });
  }

  QueryBuilder<AppNotification, AppNotification, QDistinct> distinctBySentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sentAt');
    });
  }
}

extension AppNotificationQueryProperty
    on QueryBuilder<AppNotification, AppNotification, QQueryProperty> {
  QueryBuilder<AppNotification, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppNotification, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AppNotification, bool, QQueryOperations> isSentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSent');
    });
  }

  QueryBuilder<AppNotification, String, QQueryOperations> messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'message');
    });
  }

  QueryBuilder<AppNotification, String, QQueryOperations>
      particularTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'particularTitle');
    });
  }

  QueryBuilder<AppNotification, bool, QQueryOperations> sendEmailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sendEmail');
    });
  }

  QueryBuilder<AppNotification, bool, QQueryOperations> sendPushProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sendPush');
    });
  }

  QueryBuilder<AppNotification, bool, QQueryOperations> sendSmsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sendSms');
    });
  }

  QueryBuilder<AppNotification, bool, QQueryOperations> sendWhatsappProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sendWhatsapp');
    });
  }

  QueryBuilder<AppNotification, DateTime?, QQueryOperations> sentAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sentAt');
    });
  }
}
