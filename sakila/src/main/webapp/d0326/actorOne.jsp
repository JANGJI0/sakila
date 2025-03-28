<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	// controller 단
	// 로그인 되었는지 아닌지?
	Integer staffId = (Integer)(session.getAttribute("loginStaff"));
			
	if(staffId != null) { // 로그인 상태라면
		response.sendRedirect("/sakila/index.jsp");
		return;
	}
	
	String actorId = request.getParameter("actorId");
	String actor = "";
	String title = "";
	
	// model 단
	//1)mysql 드라이버 로딩
	Class.forName("com.mysql.cj.jdbc.Driver");
		// 디버깅
		System.out.println("드라이버 로딩 성공");
	
	// 변수 받기
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	// 2) sql 준비
	String listSql = "SELECT CONCAT(a.first_name, ' ', a.last_name) actor, f.title title"
						+ " FROM film f"
						+ " INNER JOIN film_actor fa ON f.film_id = fa.film_id"
						+ " INNER JOIN actor a ON fa.actor_id = a.actor_id"
						+ " WHERE a.actor_id = ?";
	
		
		// 디버깅
		System.out.println("listSql: " + listSql);
		
	// 3) connction(접속)하기
	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
		// 디버깅
		System.out.println("DB연결성공: " + conn);
	
	// 4) 쿼리 준비
	stmt = conn.prepareStatement(listSql);
	stmt.setInt(1, Integer.parseInt(actorId));
	// 5) ResultSet 실행
	rs = stmt.executeQuery();
		// 디버깅
		System.out.println("쿼리준비완료");
		System.out.println("ResultSet: " + rs);
	
		
		ArrayList<String> titleList= new ArrayList<>();
		while(rs.next()) {
		    // 출연자 정보는 어차피 다 똑같음 (같은 actor_id)
		    actor = rs.getString("actor");
		    titleList.add(rs.getString("title")); // 출연영화는 여러개이기 때문
		
		}
		
			// 영화 + 배우 정보를 map에 저장
			HashMap<String, Object> map = new HashMap<>();
			map.put("actor", actor);
			map.put("titleList", titleList);
			
			// list를 만들어서 한번에 넣음
			ArrayList<HashMap<String, Object>> list = new ArrayList<>();
			list.add(map);
			
%>
<!-- view 단 -->

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title></title>
<style>
		 .nolink {  /*링크 밑줄 제거 */
		 	text-decoration: none;
		 	color: black; /* 필요시 색상 지정 */
		 }
		 
		 	.nolink:hover {
		 		color: #007b; /* 마우스 오버 시 색상 변경 */
		 	}
		 	/*border말고 다른 테이블 코드*/
	 	table {
	 		width: 50%;
	 		border-collapse: separate; /* 중요: collapse명 둥글게 안 보임*/
	 		border-spacing: 50;		/* 셀 간격*/
	 		border-radus: 100px;		/* 둥근 모서리*/	
	 		overflow: hidden;        /* 꼭 필요: 둥근 모서리가 잘리지 않게*/
	 		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); /* 그림자도 예쁘게*/
	 	}	
	 	th, td {
	 		padding: 12px 16px;
	 		text-align: left;
	 		background-color: #fff;
	 	}
	 	
	 	th {
	 		background-color: #f4F4F4;
	 		front-weight: bold;
	 	}
	 	
	 	th:nth-child(even) {
	 		background-color: #f9f9f9;
	 	}
	 	
	 	th:hover {
	 		background-color: #eef6ff;
	 	}
	 	
	</style>
</head>
<body>
	<!--  로그아웃 추가 -->
	<div>
		<%=staffId %>님 반갑습니다.
		<a href="/sakila/logout.jsp">로그아웃</a>
	</div>
	<h1>영화배우 상세페이지</h1>
	<table border="1">
	<%
	if (list != null && list.size() > 0) {
	//	HashMap<String, Object> map = list.get(0); // 영화 하나만 보여주기
		ArrayList<String> actors = (ArrayList<String>) map.get("titleList");
	%>
		<tr>
			<th>영화배우</th>
			<td align="center"><%=map.get("actor") %></td>
		</tr>
		
		<%
			for(int i = 0; i < actors.size(); i++) { // 출연영화 부분은 세로로 출력
		%>
			<%if (i == 0) { %>
		<tr>
			<th rowspan="<%=actors.size() %>">출연영화</th>
		<%
			}
		%>
			<td align="center"><a class="nolink" href="/sakila/d0326/filmList.jsp?filmId=<%=map.get("filmId") %>"><%= actors.get(i) %></td>  <!-- 텍스트 중앙정렬 -->
		</tr>
		<%
			}
		%>
		
	</table>
	<%
	} else {
	%>
	<p style="color:red;">❌ 출연 영화가 없습니다. (actorId=<%=actorId %>)</p>
	<%
	}
	%>
	 <a href="/sakila/d0326/actorList.jsp">영화배우 리스트로 이동</a>
</body>
</html>
<!-- SELECT f.title, f.`description` dsp
		, c.`name` cname, f.release_year releaseYer
		, CONCAT(a.first_name, ' ', a.last_name) actor
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON c.category_id = fc.category_id
INNER JOIN film_actor fa ON f.film_id = fa.film_id
INNER JOIN actor a ON fa.actor_id = a.actor_id -->
