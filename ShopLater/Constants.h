//
//  Constants.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/10/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

static NSString *sProjectName = @"ShopLater";

static NSString *sProviderCellIdentifier = @"provider";
static NSString *sProductCellIdentifier = @"product";
static NSString *sProductSortAttribute = @"priceDifference";

static NSString *sImageTypeLogo = @"logo";
static NSString *sImageTypeSection = @"section_logo";

static NSString *sPriceTypeCurrent = @"current";
static NSString *sPriceTypeWish = @"wish";

static NSString *sMenuShoppingListCell = @"shoppingList";
static NSString *sMenuStoreCell = @"store";
static NSString *sMenuHomeCellText = @"Shopping Bag";
static NSString *sMenuStoreSectionCell = @"storeSectionHeader";
static NSString *sMenuStoreSectionTitle = @"STORES";
static CGFloat   sMenuAnchorRevealAmount = 260.0f;

#define WIDESCREEN_NOT_iPAD         ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define NOT_WIDESCREEN_NOT_iPAD     ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )

// GROUNDED CAFE
#define ROOT_URL        @"http://192.168.1.10:1230"

#define CREATE_ACCT     @"/registeruser"
#define UPDATE_USR      @"/userupdate"
#define LOGIN_ACCT      @"/userlogin"
#define TOKEN_SET       @"/registerToken"
#define PROD_SET        @"/registerItem"


// NSUSER DEFAULTS VALUES
#define USER            @"userLoggedIn"
