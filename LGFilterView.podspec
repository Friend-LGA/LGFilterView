Pod::Spec.new do |s|

    s.name = 'LGFilterView'
    s.version = '1.0.3'
    s.platform = :ios, '6.0'
    s.license = 'MIT'
    s.homepage = 'https://github.com/Friend-LGA/LGFilterView'
    s.author = { 'Grigory Lutkov' => 'Friend.LGA@gmail.com' }
    s.source = { :git => 'https://github.com/Friend-LGA/LGFilterView.git', :tag => s.version }
    s.summary = 'View shows and applies different filters in iOS app'

    s.requires_arc = true

    s.source_files = 'LGFilterView/*.{h,m}'

end
