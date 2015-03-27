#!/usr/bin/perl -w
use common::sense;
use constant {
     CLOSE_FORM   => '</form>'
};
##
my $template = $ARGV[0] || 'form_template/form_horizontal.html';
my $out = $ARGV[2] || 'form.html.ep';
my %TEMP; # хэш хранящий настройки шаблона
my $cur_tag = undef;# переменная для хранения текущего тега
# читаем фал шаболна формы
open(TEMP,"<",$template) or die $!;
while (<TEMP>) {
    if (/^### (\w+) ###$/g) {
        #print $1,"\n";
        $cur_tag = $1;
    } else {
        #print $_;
        $TEMP{$cur_tag}.=$_;
    }
    
}
close(TEMP);

## читаем файл настроек формы
my $formfile = $ARGV[1] || 'descript.txt';
my @sort_fileds;
my %FORM;
open(DESCR, "<", $formfile) or die $!;
while (<DESCR>) {
    chomp;
    next if /^#/;# комменты игнорируем
    next if length($_)< 2 ;# и  строки короче 2-х символов
    my ($type,$label,$name,$id) = split /:/;
    my $key = $type . ':'.$name;
    $FORM{$key}=[$label,$id];
    push(@sort_fileds,$name);
}
close(DESCR);

my %FORM_READY;
## генерим форму
foreach my $element(keys %FORM) {
    my ($type,$name) = split(/:/,$element,2);
    my $tmp_line = $TEMP{$type};
    $tmp_line =~ s/<%= LABEL %>/$FORM{$element}->[0]/g;
    $tmp_line =~ s/<%= NAME %>/$name/g;
    $tmp_line =~ s/<%= ID %>/$FORM{$element}->[1]/g;
    $tmp_line =~ s/<%= PLACEHOLDER %>/$FORM{$element}->[2]/g;
    $FORM_READY{$name} = $tmp_line;
}

open(FILEHANDLE, ">>",$out) or die $!;
print FILEHANDLE $TEMP{form};
foreach my $line(@sort_fileds) {
    print FILEHANDLE $FORM_READY{$line},"\n";
}
print FILEHANDLE CLOSE_FORM;
print FILEHANDLE $TEMP{scripts};







