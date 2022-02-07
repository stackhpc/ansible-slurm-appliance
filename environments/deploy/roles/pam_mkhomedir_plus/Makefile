#  yum install pam-devel
CC = gcc
LD = gcc

CFLAGS = -fPIC -fno-stack-protector
LFLAGS = -shared

TARGET = pam_mkhomedir_plus

all: $(TARGET)

$(TARGET).o: $(TARGET).c
	$(CC) $(CFLAGS) -c $(TARGET).c

$(TARGET): $(TARGET).o
	$(LD) $(LFLAGS) -o $(TARGET).so $(TARGET).o

install:
	sudo cp -f $(TARGET).so /usr/lib64/security/ && chown root:root /usr/lib64/security/$(TARGET).so && chmod 755 /usr/lib64/security/$(TARGET).so

rpm:
	scons

dpkg:
	# apt-get install alien
	# mkdir -p /usr/lib64/ && ln -s /lib/x86_64-linux-gnu/security/ /usr/lib64/security
	alien *.x86_64.rpm

clean:
	rm -f $(TARGET).o $(TARGET)_test $(TARGET).so *.rpm *.spec *.tar.gz
	rm -rf pam_mkhomedir_plus-*/
	rm -rf rpmtemp/
