GDotUI={}
GDotUI.Theme={
    Global:{
        active: 'active',
        inactive: 'inactive'
    },
    Icons:{
      add:'../Themes/Chrome/images/add.png',  
      remove:'../Themes/Chrome/images/delete.png',
      edit: '../Themes/Chrome/images/pencil.png',
      handleVertical:'../Themes/Chrome/images/control_pause.png',
      handleHorizontal:''
    },
    Button:{
        'class':'button',
        defaultText: 'Button',
        defaultIcon: '../Themes/Chrome/images/pencil.png'
    },
    Float:{
        'class':'float',
        bottomHandle:'bottom',
        topHandle:'handle',
        content:'base',
        controls:'controls',
        iconOptions:{
            mode:'vertical',
            spacing:{
                x:0,
                y:5
            }
        }
    },
    Icon:{
        'class':'icon'
    },
    Overlay:{
        'class':'overlay'
    },
    Picker:{
        'class':'picker',
        event: 'click',
        picking: 'picking',
        offset: 10
    },
    Slider:{
        barClass:'bar',
        knobClass:'knob'
    },
    Slot:{
        'class':'slot'  
    },
    Tab:{
        'class':'tab'
    },
    Tabs:{
        'class':'tabs'
    },
    Tip:{
        'class':'tip',
        offset: 5,
        location: { x:"left",
                    y:"bottom" }
    },
    Date:{
      'class':'date',
      yearFrom: 1980,
      format:'%Y %B %d - %A',
      DateTime:{
        'class':'date-time',
        format:'%Y %B %d - %A %H:%M'
      },
      Time:{
        'class':'time',
        format:'%H:%M'
      }
    },
    Number:{
        'class':'number',
        range:[-100,100],
        steps:200,
        reset: true
    },
    Forms:{
        Field:{
            struct:{
                "dl":{
                    "dt":{
                        "label":''
                    },
                    "dd":{
                        "input":''
                    }
                }
            }
        }
    },
    List:{
      'class':'list'  
    },
    ListItem:{
      'class':'list-item',
      title:'title',
      subTitle:'subtitle',
      iconOffset:2
    },
    Color:{
       sb:'sb',
       hue:'hue',
       black:'black',
       white:'white',
       color:'color',
       wrapper:'wrapper',
      'class':'color',
       format: 'hsl', //[hsl,rgb,hex]
       controls:{
          'class':'control',
          format:'format',
          colorBox:'colorBox'
       },
       slotControls:{
        'class':'slotcontrol'
       }
    }
}