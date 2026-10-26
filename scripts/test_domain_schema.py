#!/usr/bin/env python3
"""Check that persisted SNA domain entities match the documented SQL schema."""

from __future__ import annotations

import re
import unittest
from pathlib import Path
from typing import Dict, List, Mapping, Sequence, Set, Tuple


ROOT = Path(__file__).resolve().parents[1]
SCHEMA_PATH = ROOT / "docs/01-ARCHITECTURE/02-SQL-SCHEMA.sql"
ENTITY_DIRS = (
    ROOT / "src/SNA.Domain/Entities/Core",
    ROOT / "src/SNA.Domain/Entities/BehaviorAnalysis",
)

# Explicit mappings make entity/table naming changes visible and keep irregular
# names from silently passing through a pluralization heuristic.
ENTITY_TABLES = {
    "Assessment": "Assessments",
    "Case": "Cases",
    "CaseTeamMember": "CaseTeamMembers",
    "Client": "Clients",
    "Diagnosis": "Diagnoses",
    "Reinforcer": "Reinforcers",
    "Baseline": "Baselines",
    "Behavior": "Behaviors",
    "BehaviorABC": "BehaviorABC",
    "GeneralizationSetting": "GeneralizationSettings",
    "PromptHierarchy": "PromptHierarchy",
    "ReplacementSkill": "ReplacementSkills",
}

PROPERTY_COLUMN_OVERRIDES = {
    "BehaviorABC.Id": "ABCId",
    "Case.CaseManagerBCBAId": "CaseManager_BCBAId",
}

SQL_TYPES_BY_CSHARP_TYPE = {
    "Guid": {"UNIQUEIDENTIFIER"},
    "DateTime": {"DATE", "DATETIME", "DATETIME2"},
    "decimal": {"DECIMAL", "NUMERIC"},
    "int": {"INT"},
    "bool": {"BIT"},
    "string": {"NVARCHAR"},
}

CLASS_RE = re.compile(
    r"\bpublic\s+(?:(?:abstract|sealed|static)\s+)*class\s+"
    r"(?P<name>\w+)(?:\s*:\s*(?P<base>\w+))?"
)
PROPERTY_RE = re.compile(
    r"\bpublic\s+"
    r"(?P<modifiers>(?:(?:virtual|override|new|static)\s+)*)"
    r"(?P<type>[\w.<>?,\[\]]+)\s+"
    r"(?P<name>[A-Za-z_]\w*)\s*\{\s*get\s*;"
)
TABLE_RE = re.compile(
    r"\bCREATE\s+TABLE\s+\[(?P<name>[^\]]+)\]\s*\((?P<body>.*?)\n\);",
    re.IGNORECASE | re.DOTALL,
)
COLUMN_RE = re.compile(
    r"^\s*\[(?P<name>[^\]]+)\]\s+"
    r"(?P<type>[A-Za-z][A-Za-z0-9]*(?:\s*\([^)]*\))?)"
    r"(?=\s|,|$)",
    re.MULTILINE,
)


def class_body(source: str, opening_brace: int) -> str:
    """Return one C# class body by balancing its braces."""
    depth = 0
    for index in range(opening_brace, len(source)):
        if source[index] == "{":
            depth += 1
        elif source[index] == "}":
            depth -= 1
            if depth == 0:
                return source[opening_brace + 1 : index]
    raise ValueError("unbalanced braces while reading a C# class")


def public_properties(body: str) -> Dict[str, str]:
    """Read persisted-looking properties, excluding navigation properties."""
    properties: Dict[str, str] = {}
    for match in PROPERTY_RE.finditer(body):
        modifiers = match.group("modifiers").split()
        property_type = match.group("type")
        if "virtual" in modifiers or property_type.startswith(("List<", "ICollection<", "IEnumerable<")):
            continue
        properties[match.group("name")] = property_type
    return properties


def read_domain_entities(entity_dirs: Sequence[Path]) -> Tuple[Dict[str, Dict[str, str]], Set[str]]:
    """Return entity properties (including BaseEntity) and declared enum names."""
    files = [path for directory in entity_dirs for path in sorted(directory.glob("*.cs"))]
    enum_names: Set[str] = set()
    entity_sources: Dict[str, Tuple[str, str]] = {}
    base_properties: Dict[str, str] = {}

    for path in files:
        source = path.read_text(encoding="utf-8")
        enum_names.update(re.findall(r"\bpublic\s+enum\s+(\w+)", source))
        for match in CLASS_RE.finditer(source):
            name = match.group("name")
            brace = source.find("{", match.end())
            if brace < 0:
                continue
            body = class_body(source, brace)
            if name == "BaseEntity":
                base_properties = public_properties(body)
            else:
                entity_sources[name] = (match.group("base") or "", body)

    entities: Dict[str, Dict[str, str]] = {}
    for name, (base_name, body) in entity_sources.items():
        if base_name != "BaseEntity":
            # These directories contain only persisted entities and their shared
            # base. A changed or missing base class must not drop an entity from
            # the comparison without a clear failure.
            entities[name] = public_properties(body)
            continue
        entities[name] = {**base_properties, **public_properties(body)}
    return entities, enum_names


def read_sql_tables(schema: str) -> Dict[str, Dict[str, str]]:
    tables: Dict[str, Dict[str, str]] = {}
    for table_match in TABLE_RE.finditer(schema):
        columns = {
            column_match.group("name"): re.sub(r"\s+", "", column_match.group("type")).upper()
            for column_match in COLUMN_RE.finditer(table_match.group("body"))
        }
        tables[table_match.group("name")] = columns
    return tables


def column_name(entity: str, property_name: str) -> str:
    override = PROPERTY_COLUMN_OVERRIDES.get(f"{entity}.{property_name}")
    if override:
        return override
    if property_name == "Id":
        return f"{entity}Id"
    return property_name


def expected_sql_types(csharp_type: str, enum_names: Set[str]) -> Set[str]:
    base_type = csharp_type.rstrip("?")
    if base_type in enum_names:
        return {"NVARCHAR"}
    return SQL_TYPES_BY_CSHARP_TYPE.get(base_type, set())


def sql_type_family(sql_type: str) -> str:
    return re.match(r"[A-Z][A-Z0-9]*", sql_type.upper()).group(0)


def compare_entity_columns(
    entity: str,
    properties: Mapping[str, str],
    columns: Mapping[str, str],
    enum_names: Set[str],
) -> List[str]:
    mapped_properties = {
        column_name(entity, name): (name, property_type)
        for name, property_type in properties.items()
    }
    issues: List[str] = []

    missing_columns = sorted(set(mapped_properties) - set(columns))
    extra_columns = sorted(set(columns) - set(mapped_properties))
    if missing_columns:
        issues.append(
            f"{entity}: model properties have no SQL columns: {', '.join(missing_columns)}"
        )
    if extra_columns:
        issues.append(
            f"{entity}: SQL columns have no model properties: {', '.join(extra_columns)}"
        )

    for column in sorted(set(mapped_properties) & set(columns)):
        property_name, property_type = mapped_properties[column]
        expected = expected_sql_types(property_type, enum_names)
        actual = sql_type_family(columns[column])
        if not expected:
            issues.append(
                f"{entity}.{property_name}: unsupported C# property type "
                f"'{property_type}'; add an explicit SQL type mapping"
            )
        elif actual not in expected:
            issues.append(
                f"{entity}.{property_name} -> [{column}]: C# type '{property_type}' "
                f"expects SQL {', '.join(sorted(expected))}, found {columns[column]}"
            )
    return issues


def validate_contract(
    entities: Mapping[str, Mapping[str, str]],
    tables: Mapping[str, Mapping[str, str]],
    enum_names: Set[str],
) -> List[str]:
    issues: List[str] = []
    expected_entities = set(ENTITY_TABLES)
    actual_entities = set(entities)

    missing_entities = sorted(expected_entities - actual_entities)
    unexpected_entities = sorted(actual_entities - expected_entities)
    if missing_entities:
        issues.append(f"domain entities missing from the comparison: {', '.join(missing_entities)}")
    if unexpected_entities:
        issues.append(
            "domain entities need an explicit SQL table mapping: "
            + ", ".join(unexpected_entities)
        )

    for entity in sorted(expected_entities & actual_entities):
        table = ENTITY_TABLES[entity]
        if table not in tables:
            issues.append(f"{entity}: expected SQL table [{table}] was not found")
            continue
        issues.extend(
            compare_entity_columns(entity, entities[entity], tables[table], enum_names)
        )
    return issues


class DomainSchemaContractTests(unittest.TestCase):
    def test_core_and_behavior_entities_match_sql_schema(self) -> None:
        entities, enum_names = read_domain_entities(ENTITY_DIRS)
        tables = read_sql_tables(SCHEMA_PATH.read_text(encoding="utf-8"))
        issues = validate_contract(entities, tables, enum_names)
        self.assertEqual([], issues, "\n".join(issues))

    def test_column_addition_or_removal_is_reported(self) -> None:
        issues = compare_entity_columns(
            "Example",
            {"Id": "Guid", "Score": "int"},
            {"ExampleId": "UNIQUEIDENTIFIER", "Unexpected": "INT"},
            set(),
        )
        self.assertTrue(
            any("model properties have no SQL columns: Score" in issue for issue in issues)
        )
        self.assertTrue(
            any("SQL columns have no model properties: Unexpected" in issue for issue in issues)
        )

    def test_sql_type_change_is_reported(self) -> None:
        issues = compare_entity_columns(
            "Example",
            {"Id": "Guid"},
            {"ExampleId": "NVARCHAR(36)"},
            set(),
        )
        self.assertTrue(
            any("expects SQL UNIQUEIDENTIFIER, found NVARCHAR(36)" in issue for issue in issues)
        )

    def test_unmapped_entity_is_reported(self) -> None:
        issues = validate_contract(
            {"Assessment": {"Id": "Guid"}, "NewEntity": {"Id": "Guid"}},
            {},
            set(),
        )
        self.assertTrue(
            any("domain entities need an explicit SQL table mapping: NewEntity" in issue for issue in issues)
        )

    def test_missing_entity_and_table_are_reported(self) -> None:
        issues = validate_contract({"Assessment": {"Id": "Guid"}}, {}, set())
        self.assertTrue(
            any("domain entities missing from the comparison:" in issue for issue in issues)
        )
        self.assertTrue(
            any("Assessment: expected SQL table [Assessments] was not found" in issue for issue in issues)
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
