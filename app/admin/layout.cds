using from '../../srv/books-service';

annotate BookService.Books with @(
    UI.HeaderInfo         : {
        TypeName      : '{i18n>HeaderTitle}',
        TypeNamePlural: '{i18n>BookInfo}',
    },
    UI.SelectionFields    : [
        isbn,
        title,
        descr,
        rating,
        currency_code
    ],
    UI.LineItem           : [
        {
            $Type             : 'UI.DataField',
            Value             : isbn,
            @HTML5.CssDefaults: {width: '10em'}
        },
        {
            $Type             : 'UI.DataField',
            Value             : title,
            @HTML5.CssDefaults: {width: '10em'}
        },
        {
            $Type             : 'UI.DataField',
            Value             : descr,
            @HTML5.CssDefaults: {width: '25em'}
        },
        {
            $Type             : 'UI.DataField',
            Value             : price,
            @HTML5.CssDefaults: {width: '5em'}
        },
        {
            $Type             : 'UI.DataField',
            Value             : currency_code,
            @HTML5.CssDefaults: {width: '5em'}
        },
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target: '@UI.DataPoint#rating',
        },
        {
            $Type             : 'UI.DataField',
            Value             : stock,
            @HTML5.CssDefaults: {width: '5em'}
        },
        {
            $Type             : 'UI.DataFieldForAction',
            Action            : 'BookService.addReview',
            Label             : '{i18n>Addreview}',
            Inline            : true,
            InvocationGrouping: #Isolated,
            @UI.Importance    : #Medium,
        },
        {
            $Type             : 'UI.DataFieldForAction',
            Action            : 'BookService.addReview',
            Label             : '{i18n>Addreview}',
            Inline            : false,
            InvocationGrouping: #Isolated,
            @UI.Importance    : #Medium,
        },
        {
            $Type         : 'UI.DataFieldForAnnotation',
            Target        : '@UI.LineItem#rating',
            Label         : '{i18n>Rating}',
            @UI.Importance: #High,
            @UI.Hidden    : true
        }

    ],
    UI.DataPoint #rating  : {
        Value        : rating,
        Visualization: #Rating,
        TargetValue  : 5
    },
    UI.PresentationVariant: {
        Text          : 'Default',
        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : isbn,
            Descending: false
        }],
        GroupBy       : [currency.code],
        Total         : [
            price,
            stock
        ],
        Visualizations: ['@UI.LineItem']
    }
);
