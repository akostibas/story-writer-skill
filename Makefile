SKILL_DIR ?= $(HOME)/.claude/skills/story-writer

.PHONY: install

# Copies rather than symlinks so the install doesn't depend on this checkout.
install:
	rm -rf "$(SKILL_DIR)"
	mkdir -p "$(SKILL_DIR)"
	cp SKILL.md "$(SKILL_DIR)/"
	@echo "Installed skill -> $(SKILL_DIR)"
