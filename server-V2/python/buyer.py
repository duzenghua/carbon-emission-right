class Buyer:
    def __init__(self, id_, order, num, price):
        self.id = id_
        self.order = order
        self.demand = num
        self.num = num
        self.price = price
        self.__seller = {}
        self.__preference = {}
        # shop是一个字典，其中键表示卖家的id，值表示交易量
        self.shop = {}

    def set_seller(self, k, v):
        self.__seller[k] = v

    # 获取偏好列表
    def set_buyer_pre(self):
        p = 1
        a_sort_list = sorted(self.__seller.items(), key=lambda x: (x[1].price, x[1].order), reverse=False)
        pre_dic = {}
        for each_s, s_obj in a_sort_list:
            pre_dic[each_s] = p
            p += 1
        self.__preference = pre_dic
        for s_, value in self.shop.items():
            value[1] = self.__preference[s_]

    # 类外访问偏好列表
    def get_pre(self, S):
        return self.__preference[S]

