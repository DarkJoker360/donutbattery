install:
	@mkdir -p $(DESTDIR)/usr/bin
	@cp -p donutbattery $(DESTDIR)/usr/bin/donutbattery
	@chmod 755 $(DESTDIR)/usr/bin/donutbattery

uninstall:
	@rm -rf $(DESTDIR)/usr/bin/donutbattery