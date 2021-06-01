.PHONY: fmt
fmt:
	@swift format \
		--ignore-unparsable-files \
		--recursive \
		--in-place \
		./Sources \
		./Tests \
		./Package.swift

.PHONY: test
test:
	@swift test
