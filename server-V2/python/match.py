import seller
import buyer
import pandas as pd
import random
random.seed(10)

def DivideB_S(a, i):
    if a[0:5] == 'buyer':
        b = a
        s = i
    else:
        b = i
        s = a
    return b, s


class Match:
    def __init__(self):
        self.seller = {}
        self.buyer = {}
        # I表示内部稳定的集合，S 表示还不在T_中的集合
        self.S = []
        self.I = []
        # I_迭代用
        self.I_ = []
        self.buyer_num = 0
        self.seller_num = 0
        self.matched = pd.DataFrame()

    # 读数据，实例化卖家和买家的对象
    def init_participant(self):
        sellInfoDf = pd.read_excel(r'E:\downloads\declare.xlsx', sheet_name=0, usecols='B,C,D,E', header=None)
        buyInfoDf = pd.read_excel(r'E:\downloads\declare.xlsx', sheet_name=1, usecols='B,C,D,E',header=None)
        sellInfoArr = sellInfoDf.values
        buyInfoArr = buyInfoDf.values
        sellNum = len(sellInfoDf)
        buyNum = len(buyInfoDf)
        b_num = 0
        s_num = 0
        for i in range(sellNum):
            self.seller[sellInfoArr[i, 0]] = seller.Seller(sellInfoArr[i, 0], self.seller_num + sellInfoArr[i, 1],
                                                           sellInfoArr[i, 2],sellInfoArr[i, 3])
            self.matched[sellInfoArr[i, 0]] = ('*', '*') * len(self.matched)
            s_num += 1
            self.I.append(sellInfoArr[i, 0])
        for j in range(buyNum):
            self.buyer[buyInfoArr[j, 0]] = buyer.Buyer(buyInfoArr[j, 0], self.buyer_num + buyInfoArr[j, 1],
                                                       buyInfoArr[j, 2], buyInfoArr[j, 3])
            self.matched.loc[buyInfoArr[j, 0]] = [('*', '*')] * len(self.matched.columns)
            b_num += 1
            self.I.append(buyInfoArr[j, 0])
        self.buyer_num += b_num
        self.seller_num += s_num
        # 初始化偏好列表
        for b_key, b_obj in self.buyer.items():
            for s_key, s_obj in self.seller.items():
                if b_obj.price >= s_obj.price:
                    b_obj.set_seller(s_key, s_obj)
                    s_obj.set_buyer(b_key, b_obj)
        self.refresh_preference()
        # self.S 初始是与self.I一样的集合
        self.S = self.I.copy()

    # 新的时隙
    def set_new_time_slot(self, path):
        b_list = self.buyer.keys()
        s_list = self.seller.keys()
        for each_b in b_list:
            if self.buyer[each_b].num == 0:
                del self.buyer[each_b]
                self.matched.drop(each_b)
                self.I.remove(each_b)

        for each_s in s_list:
            if self.seller[each_s].num == 0:
                del self.seller[each_s]
                self.matched.drop(each_s, axis=1)
                self.I.remove(each_s)

        # 读新时隙的数据
        self.init_participant()

    # 为所有卖家与买家更新偏好列表
    def refresh_preference(self):
        for b_obj in self.buyer.values():
            b_obj.set_buyer_pre()
        for s_obj in self.seller.values():
            s_obj.set_seller_pre()

    # RPPS_base算法
    def match_main(self):
        while set(self.I) != set(self.I_):
            a = self.select_agent()
            flag_1 = True
            for each_i in self.I_:
                if self.Is_Block(a, each_i):
                    self.Deal_Block(a, each_i)
                    flag_1 = False
            if flag_1:
                continue
            flag_2 = True
            while flag_2:
                flag_2 = False
                for each_b in self.buyer.keys():
                    for each_s in self.seller.keys():
                        if self.Is_Block(each_b, each_s):
                            self.Deal_Block(each_b, each_s)
                            flag_2 = True

            # flag_2 = True
            # while flag_2:
            #     flag_2 = False
            #     for each_s in self.seller.keys():
            #         for each_b in self.buyer.keys():
            #             if self.Is_Block(each_b, each_s):
            #                 self.Deal_Block(each_b, each_s)
            #                 flag_2 = True

    # 输出匹配结果
    def print_result(self):
        buy_sati = 0
        for each_b in self.buyer.keys():
            b_trade_num = self.buyer[each_b].demand - self.buyer[each_b].num
            if b_trade_num == 0:
                b_sati = 0
                print(each_b, b_sati)
                continue
            b_price = b_trade_num * self.buyer[each_b].price
            # print(each_b, self.buyer[each_b].shop)
            min_s = None
            sum_value = 0
            if self.buyer[each_b].shop:
                for e_s, n in self.buyer[each_b].shop.items():
                    trans_price = (self.buyer[each_b].price + self.seller[e_s].price) / 2
                    sum_value += (trans_price * n[0])
                    v = (n[0], trans_price)
                    print(each_b, e_s)
                    self.matched.loc[each_b, e_s] = str(v)
                    if min_s is None or self.seller[min_s].price > self.seller[e_s].price:
                        min_s = e_s
                min_b_v = b_trade_num * self.seller[min_s].price
            # b_sati = (b_price - sum_value) / (b_price - min_b_v)
            b_sati = (b_price - sum_value) / b_price
            buy_sati += b_sati
            print(each_b, b_sati)
        sell_sati = 0
        for each_s in self.seller.keys():
            s_trade_num = self.seller[each_s].sale - self.seller[each_s].num
            if s_trade_num == 0:
                s_sati = 0
                print(each_s, s_sati)
                continue
            s_price = s_trade_num * self.seller[each_s].price
            max_b = None
            sum_v = 0
            if self.seller[each_s].buy:
                for e_b, val in self.seller[each_s].buy.items():
                    sum_v += (int(self.matched.loc[e_b, each_s][1]) * val[0])
                    if max_b is None or self.buyer[max_b].price < self.buyer[e_b].price:
                        max_b = e_b
                max_s_v = self.buyer[max_b].price * s_trade_num

            # if max_s_v == s_price:
            #     s_sati = 1
            # else:
            #     s_sati = (sum_v - s_price) / (max_s_v - s_price)
            s_sati = (sum_v - s_price) / s_price
            sell_sati += s_sati
            print(each_s, s_sati)
            # print(each_s, self.seller[each_s].buy)
        print('****************')
        print(buy_sati, sell_sati)
        # print(self.matched)
        self.matched.to_excel("matched.xlsx")

    # 将一个agent添加到self.I_中
    def select_agent(self):
        a = random.choice(self.S)
        self.I_.append(a)
        self.S.remove(a)
        return a

    def Is_Block(self, a, i):
        if a[0:5] == i[0:5]:
            return False
        # 确定a和i谁是买家，谁是卖家
        b, s = DivideB_S(a, i)
        if self.buyer[b].price < self.seller[s].price:
            return False
        b_flag = False
        s_flag = False
        if self.buyer[b].num > 0:
            b_flag = True
        else:
            for each_s in self.buyer[b].shop.keys():
                if self.buyer[b].get_pre(s) < self.buyer[b].get_pre(each_s):
                    b_flag = True
                    break
        if self.seller[s].num > 0:
            s_flag = True
        else:
            for each_b in self.seller[s].buy.keys():
                if self.seller[s].get_pre(b) < self.seller[s].get_pre(each_b):
                    s_flag = True
                    break
        return b_flag and s_flag

    def Deal_Block(self, a, i):
        b, s = DivideB_S(a, i)
        vol_b = self.buyer[b].num
        vol_s = self.seller[s].num
        # b_rej与b_rej中的元素都是有两个值的list，第一个表示id，第二个是在b/s偏好列表中的位置
        b_rej = []
        s_rej = []
        for each_b in self.seller[s].buy.keys():
            if self.seller[s].get_pre(b) < self.seller[s].get_pre(each_b):
                s_rej.append([each_b, self.seller[s].get_pre(each_b)])
                vol_s += self.seller[s].buy[each_b][0]

        for each_s in self.buyer[b].shop.keys():
            if self.buyer[b].get_pre(s) < self.buyer[b].get_pre(each_s):
                b_rej.append([each_s, self.buyer[b].get_pre(each_s)])
                vol_b += self.buyer[b].shop[each_s][0]
        vol = min(vol_b, vol_s)

        b_rej = sorted(b_rej, key=lambda x: x[1], reverse=True)
        s_rej = sorted(s_rej, key=lambda x: x[1], reverse=True)
        if vol > self.buyer[b].num:
            refuse = vol - self.buyer[b].num
            for each_s in b_rej:
                if refuse < self.buyer[b].shop[each_s[0]][0]:
                    self.buyer[b].shop[each_s[0]][0] -= refuse
                    self.seller[each_s[0]].buy[b][0] -= refuse
                    # self.matched.loc[b, each_s[0]] -= refuse
                    self.buyer[b].num += refuse
                    self.seller[each_s[0]].num += refuse
                    break
                else:
                    refuse -= self.buyer[b].shop[each_s[0]][0]
                    self.buyer[b].num += self.buyer[b].shop[each_s[0]][0]
                    self.seller[each_s[0]].num += self.seller[each_s[0]].buy[b][0]
                    # self.matched.loc[b, each_s[0]] = 0
                    del self.buyer[b].shop[each_s[0]]
                    del self.seller[each_s[0]].buy[b]
        if vol > self.seller[s].num:
            refuse = vol - self.seller[s].num
            for each_b in s_rej:
                if refuse < self.seller[s].buy[each_b[0]][0]:
                    self.seller[s].buy[each_b[0]][0] -= refuse
                    self.buyer[each_b[0]].shop[s][0] -= refuse
                    # self.matched.loc[each_b[0], s] -= refuse
                    self.seller[s].num += refuse
                    self.buyer[each_b[0]].num += refuse
                    break
                else:
                    refuse -= self.seller[s].buy[each_b[0]][0]
                    self.seller[s].num += self.seller[s].buy[each_b[0]][0]
                    self.buyer[each_b[0]].num += self.buyer[each_b[0]].shop[s][0]
                    # self.matched.loc[each_b[0], s] = 0
                    del self.buyer[each_b[0]].shop[s]
                    del self.seller[s].buy[each_b[0]]
        # 建立匹配
        self.buyer[b].num -= vol
        self.seller[s].num -= vol
        # self.matched.loc[b, s] += vol
        if b in self.seller[s].buy.keys():
            self.seller[s].buy[b][0] += vol
        else:
            self.seller[s].buy[b] = [vol, self.seller[s].get_pre(b)]
        if s in self.buyer[b].shop.keys():
            self.buyer[b].shop[s][0] += vol
        else:
            self.buyer[b].shop[s] = [vol, self.buyer[b].get_pre(s)]


if __name__ == "__main__":
    m = Match()
    m.init_participant()
    m.match_main()
    m.print_result()



