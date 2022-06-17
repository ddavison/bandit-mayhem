# Attributes

# Dialog

## Informational
```yaml
- name: My NPC
  dialog:
    This is purely informational: Ok
```

## Optional

```yaml
- name: My NPC
  dialog:
    This dialog has options:
      If you go here: I say this
      If you go there: I say that
```

## Nested

```yaml
- name: My NPC
  dialog:
    This dialog has nested options:
      If you go here:
        I say this: You say that
        I say that: You say this
```

# Gabbi Strick
# Tristo Ultrath
